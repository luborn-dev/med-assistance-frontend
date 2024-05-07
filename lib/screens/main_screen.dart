import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'MedAssistance',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bem-vindo!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(width: 1, color: Colors.black),
                ),
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 40),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  side: BorderSide(width: 1, color: Colors.black),
                ),
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 40),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
              child: const Text('Cadastro'),
            ),
          ],
        ),
      ),
    );
  }
}
