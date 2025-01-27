part of janus_client;

class JanusRecordPlayPlugin extends JanusPlugin {
  JanusRecordPlayPlugin({handleId, context, transport, session})
      : super(
          context: context,
          handleId: handleId,
          plugin: JanusPlugins.RECORD_PLAY,
          session: session,
          transport: transport);

  /// [record]
  /// Start recording a session with a JSEP offer.
  ///
  /// [name]: Pretty name for the recording.
  /// [id]: Optional unique numeric ID for the recording.
  /// [filename]: Optional base path/name for the file.
  /// [audiocodec]: Optional preferred audio codec for the recording.
  /// [videocodec]: Optional preferred video codec for the recording.
  /// [videoprofile]: Optional video profile to use (e.g., "2" for VP9, "42e01f" for H.264).
  /// [opusred]: Optional, whether RED should be negotiated for audio (default=false).
  /// [textdata]: Optional, whether recorded data channels will be text (default) or binary.
  /// [jsep]: The SDP offer for the recording PeerConnection.
  Future<int> record(String name, {
    int? id,
    String? filename,
    String? audiocodec,
    String? videocodec,
    String? videoprofile,
    bool opusred = false,
    bool textdata = false
  }) async {
    var payload = {
      "request": "record",
      "id": id,
      "name": name,
      "filename": filename,
      "audiocodec": audiocodec,
      "videocodec": videocodec,
      "videoprofile": videoprofile,
      "opusred": opusred,
      "textdata": textdata,
    }..removeWhere((key, value) => value == null);


    RTCSessionDescription offer = await this.createOffer(videoRecv: false, audioRecv: true);
    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload, jsep: offer));
    JanusError.throwErrorFromEvent(response);
    return response.plugindata?.data["id"] ?? 0;
  }

  /// [stop]
  /// Stops an ongoing recording or playback.
  Future<void> stop() async {
    var payload = {
      "request": "stop",
    };
    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload));
    JanusError.throwErrorFromEvent(response);
  }

  /// [play]
  /// Prepare playback of a previously recorded file.
  ///
  /// [id]: The unique numeric ID of the recording to replay.
  Future<void> play(int id) async {
    var payload = {
      "request": "play",
      "id": id,
    };

    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload));
    JanusError.throwErrorFromEvent(response);
  }

  /// [start]
  /// Starts the playback process for a prepared recording.
  ///
  /// [jsep]: The SDP answer for the playback PeerConnection.
  Future<void> start() async {
    var payload = {
      "request": "start"
    };
    
    var answer  = await this.createAnswer();
    
    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload, jsep: answer));
    JanusError.throwErrorFromEvent(response);
  }

  Future<void> startRecording(String name) async {
    final offer = await this.createOffer();
    final body = {
      "request": "record",
      "name": name,
    };

    final message = {
      "janus": "message",
      "body": body,
      "jsep": offer.toMap()
    };

    JanusEvent response = JanusEvent.fromJson(await this.send(data: message));
    JanusError.throwErrorFromEvent(response);
  }

  /// [list]
  /// List all recordings available.
  Future<List<RecordPlayFile>> list() async {
    var payload = {
      "request": "list",
    };

    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload));
    JanusError.throwErrorFromEvent(response);

    var files = response.plugindata?.data["list"] as List<dynamic>;
    return files.map((file) => RecordPlayFile.fromJson(file)).toList();
  }

  /// [update]
  /// Force the plugin to refresh the recordings folder.
  Future<void> update() async {
    var payload = {
      "request": "update",
    };

    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload));
    JanusError.throwErrorFromEvent(response);
  }

  /// [hangup]
  /// Handle hangup and stop any ongoing operations.
  @override
  Future<void> hangup() async {
    await super.hangup();
    await this.stop();
  }

  @override
  void onCreate() {
    super.onCreate();
    if (_onCreated) {
      return;
    }
    _onCreated = true;

    messages?.listen((event) {
      TypedEvent<JanusEvent> typedEvent =
          TypedEvent<JanusEvent>(event: JanusEvent.fromJson(event.event), jsep: event.jsep);


      var data = typedEvent.event.plugindata?.data;
      if (data == null) return;

      if (data["recordplay"] == "event") {
        if (data["error_code"] != null) {
          _typedMessagesSink?.addError(JanusError.fromMap(data));
        } else {
          _typedMessagesSink?.add(typedEvent);
        }
      }
    });
  }

  bool _onCreated = false;
}

class RecordPlayFile {
  final int id;
  final String name;
  final DateTime date;
  final bool? audio;
  final bool? video;
  final bool? data;
  final String? audioCodec;
  final String? videoCodec;

  RecordPlayFile({
    required this.id,
    required this.name,
    required this.date,
    this.audio,
    this.video,
    this.data,
    this.audioCodec,
    this.videoCodec,
  });

  factory RecordPlayFile.fromJson(Map<String, dynamic> json) {
    return RecordPlayFile(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      audio: json['audio'],
      video: json['video'],
      data: json['data'],
      audioCodec: json['audio_codec'],
      videoCodec: json['video_codec'],
    );
  }
}

class RecordPlayEvent {
  final String status;

  RecordPlayEvent({required this.status});

  factory RecordPlayEvent.fromJson(Map<String, dynamic> json) {
    return RecordPlayEvent(
      status: json['status'],
    );
  }
}
