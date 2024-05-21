import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedAssistance'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Padding around the buttons
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // Stretch buttons across the screen width
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/preRecording');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                // Text color
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0), // Button padding
              ),
              child: const Text('Gravar Procedimento'),
            ),
            const SizedBox(height: 20), // Space between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/player');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                // Text color
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0), // Button padding
              ),
              child: const Text('Gerenciar Gravações'),
            ),
            const SizedBox(height: 20), // Space between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/manageAccount');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                // Text color
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0), // Button padding
              ),
              child: const Text('Minha conda'),
            ),
          ],
        ),
      ),
    );
  }
}
