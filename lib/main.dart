import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_assistance_frontend/screens/loading_screen.dart';
import 'package:med_assistance_frontend/screens/patient_registration_screen.dart';
import 'package:med_assistance_frontend/screens/welcome_screen.dart';
import 'package:med_assistance_frontend/screens/login_screen.dart';
import 'package:med_assistance_frontend/screens/signup_screen.dart';
import 'package:med_assistance_frontend/screens/main_screen.dart';
import 'package:med_assistance_frontend/screens/recording_screen.dart';
import 'package:med_assistance_frontend/screens/profile_screen.dart';
import 'package:med_assistance_frontend/screens/pre_recording_screen.dart';
import 'package:med_assistance_frontend/screens/manage_recordings_screen.dart';

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
        '/manageRecordings': (context) =>  ManageRecordingsScreen(),
        '/patientregistration': (context) =>  PatientRegistrationScreen(),
      },
    );
  }
}
