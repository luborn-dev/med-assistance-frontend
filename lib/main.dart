import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_assistance_frontend/screens/access/login_screen.dart';
import 'package:med_assistance_frontend/screens/access/signup_screen.dart';
import 'package:med_assistance_frontend/screens/faq/faq_screen.dart';
import 'package:med_assistance_frontend/screens/access/loading_screen.dart';
import 'package:med_assistance_frontend/screens/registration/patient_registration_screen.dart';
import 'package:med_assistance_frontend/screens/home_screen.dart';
import 'package:med_assistance_frontend/screens/recording/recording_screen.dart';
import 'package:med_assistance_frontend/screens/profile/profile_screen.dart';
import 'package:med_assistance_frontend/screens/recording/pre_recording_screen.dart';
import 'package:med_assistance_frontend/screens/recording/manage_recordings_screen.dart';

Future<void> main(List<String> args) async {
  final environment = args.isNotEmpty ? args[0] : 'dev';

  await dotenv.load(fileName: ".env.$environment");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Med Assistance',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
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
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainScreen(),
        '/manageAccount': (context) => const ProfileScreen(),
        '/preRecording': (context) => const PreRecordingScreen(),
        '/manageRecordings': (context) => ManageRecordingsScreen(),
        '/patientregistration': (context) => PatientRegistrationScreen(),
        '/faq': (context) => FaqScreen(),
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.light(
        primary: Colors.blue.shade600,
        secondary: Colors.green.shade400,
        error: Colors.red.shade400,
        surface: Colors.grey.shade50,
      ),
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800),
        titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade700),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.grey.shade800),
        titleMedium: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue.shade600,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.blue.shade600),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: Colors.blue.shade300,
        secondary: Colors.green.shade300,
        error: Colors.red.shade300,
        surface: Colors.grey.shade900,
      ),
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        displayLarge: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white70),
        bodyLarge: const TextStyle(fontSize: 16, color: Colors.white70),
        titleMedium: const TextStyle(fontSize: 14, color: Colors.white60),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue.shade300,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade300,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        labelStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.blue.shade300),
        ),
      ),
    );
  }
}
