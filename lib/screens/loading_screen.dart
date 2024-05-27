import 'package:flutter/material.dart';
import 'dart:async';

import 'package:med_assistance_frontend/widget/gradient_container.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Delay of 3 seconds
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GradientContainer(
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
              CircularProgressIndicator(color: Colors.black,), // Loading icon
            ],
          ),
        ),
      ),
    );
  }
}
