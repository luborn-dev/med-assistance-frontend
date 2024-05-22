import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_assistance_frontend/screens/loading_screen.dart';
import 'package:med_assistance_frontend/screens/player_screen.dart';
import 'package:med_assistance_frontend/screens/welcome_screen.dart';
import 'package:med_assistance_frontend/screens/login_screen.dart';
import 'package:med_assistance_frontend/screens/signup_screen.dart';
import 'package:med_assistance_frontend/screens/main_screen.dart';
import 'package:med_assistance_frontend/screens/recording_screen.dart';
import 'package:med_assistance_frontend/screens/profile_screen.dart';
import 'package:med_assistance_frontend/screens/preRecording_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Med Assistance',
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
      home: const LoadingScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/recording') {
          final procedureData = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return RecordingScreen(procedureData: procedureData);
            },
          );
        }
        return null;
      },
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainScreen(),
        '/manageAccount': (context) => const ProfileScreen(),
        '/preRecording': (context) => const PreRecordingScreen(),
        '/player': (context) => const PlayRecordingScreen(filePath: "/data/user/0/com.example.med_assistance_frontend/app_flutter/myRecording.m4a"),
      },
    );
  }
}
