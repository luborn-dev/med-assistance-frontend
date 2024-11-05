import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/components/background_container.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BackgroundContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/logo.png'),
                width: 300, // Adjust size according to your preference
                height: 300,
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(
                color: Colors.black,
              ), // Loading icon
            ],
          ),
        ),
      ),
    );
  }
}
