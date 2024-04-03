import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'pages/Signin_Signup/signinpage.dart';
import 'pages/Signin_Signup/signuppage.dart';
import 'pages/assistant.dart';
import 'pages/diet.dart';
import 'pages/homepage.dart';
import 'pages/profile_page.dart';
import 'pages/splashscreen.dart';
import 'pages/timer.dart';
import 'pages/workout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  // Request necessary permissions here
  await _requestPermissions();
}

Future<void> _requestPermissions() async {
  try {
    // Request camera and photo library permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();

    // Check if permissions are granted
    if (statuses[Permission.camera] == PermissionStatus.granted) {
      // Both camera and photo library permissions are granted
      print(
          'Camera and photo library permissions granted. Proceed to the next steps in your app.');
    } else {
      // Handle the case where one or both permissions are not granted
      // You may want to show an alert to inform the user or take appropriate actions
      print('Camera and/or photo library permissions not granted.');
    }
  } catch (e) {
    // Handle exceptions if there are any issues with the permission request
    print('Error requesting permissions: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FITGEEK',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/splash', // Set the initial route to SplashScreen
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/workout': (context) => const Workout(),
        '/timer': (context) => const CustomTimer(),
        '/diet': (context) => const Diet(),
        '/assistant': (context) => const ChatGptPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
