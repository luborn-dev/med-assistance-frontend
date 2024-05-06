import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/signUp_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/main': (context) => const MainScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
