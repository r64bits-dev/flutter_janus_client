import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:janus_client/janus_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';
import 'package:janus_client_example/conf.dart';

class RecordPlayExample extends StatefulWidget {
  @override
  _RecordPlayState createState() => _RecordPlayState();
}

class _RecordPlayState extends State<RecordPlayExample> {
  JanusClient? client;
  JanusSession? session;
  JanusRecordPlayPlugin? recordPlay;
  late WebSocketJanusTransport ws;
  List<RecordPlayFile> recordings = [];
  TextEditingController fileNameController = TextEditingController();
  bool recording = false;
  bool playing = false;

  @override
  void initState() {
    super.initState();
    initializeClient();
  }

  Future<void> initializeClient() async {
    ws = WebSocketJanusTransport(url: servermap['servercheap']);
    client = JanusClient(
      withCredentials: true,
      isUnifiedPlan: true,
      stringIds: false,
      apiSecret: "SecureIt",
      transport: ws,
      iceServers: [RTCIceServer(urls: "stun:stun1.l.google.com:19302")],
    );
    session = await client?.createSession();
    recordPlay = await session?.attach<JanusRecordPlayPlugin>();
    await listRecordings();
  }

  Future<void> startRecording() async {
    String fileName = fileNameController.text.trim();
    if (fileName.isNotEmpty) {
      try {
        var offer = await recordPlay?.createOffer(audioRecv: true, videoRecv: false);
        await recordPlay?.record(fileName, jsep: offer!.sdp!);
        setState(() {
          recording = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording started: $fileName')),
        );
        await listRecordings();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting recording: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a valid file name.')),
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      await recordPlay?.stop();
      setState(() {
        recording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording stopped')),
      );
      await listRecordings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  Future<void> playRecording(int id) async {
    try {
      await recordPlay?.play(id);
      setState(() {
        playing = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playing recording: $id')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing recording: $e')),
      );
    }
  }

  Future<void> listRecordings() async {
    try {
      recordings = await recordPlay?.list() ?? [];
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recordings: $e')),
      );
    }
  }

  @override
  void dispose() {
    recordPlay?.dispose();
    session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: listRecordings,
          ),
        ],
        title: const Text('Record and Play'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: fileNameController,
              decoration: InputDecoration(
                labelText: 'Recording File Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: !recording ? startRecording : null,
                  child: Text('Start Recording'),
                ),
                ElevatedButton(
                  onPressed: recording ? stopRecording : null,
                  child: Text('Stop Recording'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: recordings.length,
                itemBuilder: (context, index) {
                  var recording = recordings[index];
                  return ListTile(
                    title: Text(recording.name),
                    subtitle: Text('Date: ${recording.date}'),
                    trailing: IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: !playing ? () => playRecording(recording.id) : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
