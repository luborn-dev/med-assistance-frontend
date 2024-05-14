import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/logo.png'),
              width: 300, // Adjust size according to your preference
              height: 300,
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
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  side: BorderSide(width: 2, color: Colors.black),
                ),
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 60),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Login', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  side: BorderSide(width: 2, color: Colors.black),
                ),
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 60),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
              child: const Text('Cadastro', style: TextStyle(fontSize: 32)),
            ),
          ],
        ),
      ),
    );
  }
}
