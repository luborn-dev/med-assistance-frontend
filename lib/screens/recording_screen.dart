import 'package:flutter/material.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool isRecording = false;

  void toggleRecording() {
    setState(() {
      isRecording = !isRecording;
      print(isRecording);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('MedAssistance'),
        // centerTitle: true,
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
              icon: Icon(isRecording ? Icons.stop_circle : Icons.circle),
              iconSize: 100,
              onPressed: toggleRecording,
              color: Colors.black,
            ),
            const SizedBox(height: 10),
            Text(isRecording ? 'Parar' : 'Iniciar'),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Finalize recording logic
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                padding: const EdgeInsets.symmetric(vertical: 16.0), // Button padding
              ),
              child: const Text('Finalizar'),
            ),
          ],
        ),
      ),
    );
  }
}
