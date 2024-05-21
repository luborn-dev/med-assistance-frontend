import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayRecordingScreen extends StatefulWidget {
  final String filePath;

  const PlayRecordingScreen({Key? key, required this.filePath})
      : super(key: key);

  @override
  _PlayRecordingScreenState createState() => _PlayRecordingScreenState();
}

class _PlayRecordingScreenState extends State<PlayRecordingScreen> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    try {
      await _player.setFilePath(widget.filePath);
      await _player.play();
    } catch (e) {
      print("An error occurred while playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Recorded Audio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/main');
          },
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _playAudio,
          child: Text('Play Recording'),
        ),
      ),
    );
  }
}
