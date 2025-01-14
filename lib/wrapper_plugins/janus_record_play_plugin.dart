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
  /// [video]: Boolean indicating if video should also be recorded.
  /// [audio]: Boolean indicating if audio should also be recorded.
  Future<void> record(String name, {bool? video, bool? audio}) async {
    var payload = {
      "request": "record",
      "name": name,
      "video": video,
      "audio": audio,
    }..removeWhere((key, value) => value == null);
    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload));
    JanusError.throwErrorFromEvent(response);
  }

  /// [stopRecording]
  /// Stops an ongoing recording.
  ///
  /// [name]: Name of the recording file to stop.
  Future<void> stopRecording(String name) async {
    var payload = {
      "request": "stop",
      "name": name,
    };
    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload));
    JanusError.throwErrorFromEvent(response);
  }

  /// [play]
  /// Play a previously recorded file.
  ///
  /// [name]: Name of the recording file to play.
  /// [video]: Boolean indicating if video should also be played.
  /// [audio]: Boolean indicating if audio should also be played.
  Future<void> play(String name, {bool? video, bool? audio}) async {
    var payload = {
      "request": "play",
      "name": name,
      "video": video,
      "audio": audio,
    }..removeWhere((key, value) => value == null);
    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload));
    JanusError.throwErrorFromEvent(response);
  }

  /// [pause]
  /// Pause playback of a recorded file.
  Future<void> pause() async {
    var payload = {
      "request": "pause",
    };
    JanusEvent response = JanusEvent.fromJson(await this.send(data: payload));
    JanusError.throwErrorFromEvent(response);
  }

  /// [stopPlayback]
  /// Stop playback of a recorded file.
  Future<void> stopPlayback() async {
    var payload = {
      "request": "stop",
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
    var files = response.plugindata?.data["recordings"] as List<dynamic>;
    return files.map((file) => RecordPlayFile.fromJson(file)).toList();
  }

  /// [hangup]
  /// Handle hangup and stop any ongoing operations.
  @override
  Future<void> hangup() async {
    await super.hangup();
    await this.send(data: {"request": "stop"});
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
        if (data["result"] == "ok") {
          typedEvent.event.plugindata?.data = RecordPlayEvent.fromJson(data);
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
  final String name;
  final int size;
  final DateTime created;

  RecordPlayFile({required this.name, required this.size, required this.created});

  factory RecordPlayFile.fromJson(Map<String, dynamic> json) {
    return RecordPlayFile(
      name: json['name'],
      size: json['size'],
      created: DateTime.parse(json['created']),
    );
  }
}

class RecordPlayEvent {
  final String name;
  final String status;

  RecordPlayEvent({required this.name, required this.status});

  factory RecordPlayEvent.fromJson(Map<String, dynamic> json) {
    return RecordPlayEvent(
      name: json['name'],
      status: json['status'],
    );
  }
}
