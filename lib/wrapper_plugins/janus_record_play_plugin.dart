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
  /// Start recording a session. You can specify the file path and other optional parameters.
  ///
  /// [name]: Name of the recording file.
  /// [audiocodec]: Optional preferred audio codec for the recording.
  /// [videocodec]: Optional preferred video codec for the recording.
  /// [filename]: Optional base path/name for the file.
  Future<int> record(String name, {String? audiocodec, String? videocodec, String? filename}) async {
    var payload = {
      "request": "record",
      "name": name,
      "audiocodec": audiocodec,
      "videocodec": videocodec,
      "filename": filename,
    }..removeWhere((key, value) => value == null);

    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload));
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
  Future<void> start(String jsep) async {
    var payload = {
      "request": "start",
      "jsep": {
        "type": "answer",
        "sdp": jsep,
      },
    };

    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload));
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
        if (data["result"] == "done") {
          _typedMessagesSink?.add(typedEvent);
        } else if (data["error_code"] != null) {
          _typedMessagesSink?.addError(JanusError.fromMap(data));
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