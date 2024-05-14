import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/loading_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'screens/recording_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedAssistance',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xffCAF4FF), // Default background color
        elevatedButtonTheme: const ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xff7ad1e3)))),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xffCAF4FF), // Apply same color to AppBar
          foregroundColor: Colors.black, // Customize text/icon color in AppBar
        ),
        // Apply the background color to other surfaces as well
        cardColor: const Color(0xffCAF4FF),
        dialogBackgroundColor: const Color(0xffCAF4FF),
        canvasColor: const Color(0xffCAF4FF),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainScreen(),
        '/recording': (context) => const RecordingScreen(),
      },
    );
  }
}
