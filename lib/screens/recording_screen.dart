import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart'; // Import necessário

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final record = AudioRecorder();
  bool isRecording = false;
  String? recordingPath;

  @override
  void initState() {
    super.initState();
    prepareRecordingPath().then((_) {
      requestPermission();
    });
  }

  Future<void> prepareRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    recordingPath = '${directory.path}/myRecording.m4a';
  }

  Future<void> requestPermission() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Needed"),
          content: const Text("This app requires microphone access to record audio."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> toggleRecording() async {
    final isCurrentlyRecording = await record.isRecording();
    if (!isCurrentlyRecording) {
      if (await record.hasPermission()) {
        if (recordingPath == null) {
          await prepareRecordingPath();
        }
        await record.start(const RecordConfig(), path: recordingPath!);

        setState(() => isRecording = true);
      }
    } else {
      final path = await record.stop();
      setState(() => isRecording = false);
      print('Recording stopped! File saved at: $path');
      if (path != null && await File(path).length() > 0) {
        await _sendRecording(path);
      } else {
        print('Recording file is empty or does not exist.');
      }
    }
  }

  Future<void> _sendRecording(String filePath) async {
    try {
      var url = Uri.parse('http://10.0.2.2:8000/api/procedures/upload');
      var request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType('audio', 'mp4'), // Definindo explicitamente o tipo de mídia
        ));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Upload completo.');
      } else {
        print('Erro ao enviar o arquivo.');
        print('Status Code: ${response.statusCode}');
        print('Response: ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print('Erro ao enviar o arquivo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/main');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(isRecording ? Icons.stop : Icons.mic),
              onPressed: toggleRecording,
              color: !isRecording ? Colors.black : Colors.red,
              iconSize: 100,
            ),
            const SizedBox(height: 24),
            Text(isRecording ? "Tap to Stop" : "Tap to Record"),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    record.dispose();
    super.dispose();
  }
}
