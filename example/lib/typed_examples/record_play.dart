import 'package:flutter/material.dart';
import 'package:janus_client/janus_client.dart';
import 'package:janus_client_example/conf.dart';

class RecordPlayExample extends StatefulWidget {
  @override
  _RecordPlayExampleState createState() => _RecordPlayExampleState();
}

class _RecordPlayExampleState extends State<RecordPlayExample> {
  late JanusClient client;
  late JanusSession session;
  late JanusRecordPlayPlugin recordPlay;
  List<RecordPlayFile> recordings = [];
  TextEditingController fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeClient();
  }

  @override
  void dispose() {
    recordPlay.dispose();
    session.dispose();
    super.dispose();
  }

  Future<void> initializeClient() async {
    client = JanusClient(
      withCredentials: true,
      apiSecret: "janusrocks",
      transport: RestJanusTransport(url: servermap['janus_rest']),
      iceServers: [RTCIceServer(urls: "stun:stun1.l.google.com:19302")],
    );
    session = await client.createSession();
    recordPlay = await session.attach<JanusRecordPlayPlugin>();
    await recordPlay.initializeMediaDevices(mediaConstraints: {"audio": true, "video": false});
      
    await listRecordings();
  }

   Future<void> startRecording() async {
    String fileName = fileNameController.text.trim();
    if (fileName.isNotEmpty) {
      try {
        // Cria uma oferta para negociação de mídia
        var offer = await recordPlay.createOffer(audioRecv: true, videoRecv: true);

        // Chama o método record com o JSEP gerado
        int recordingId = await recordPlay.record(
          fileName,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording started: $fileName (ID: $recordingId)')),
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
      await recordPlay.stop();
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
      await recordPlay.play(id);
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
      recordings = await recordPlay.list();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recordings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RecordPlay Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: listRecordings,
          ),
        ],
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
                  onPressed: startRecording,
                  child: Text('Start Recording'),
                ),
                ElevatedButton(
                  onPressed: stopRecording,
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
                      onPressed: () => playRecording(recording.id),
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
