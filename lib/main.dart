import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minutes_summary/Homepage.dart';
import 'package:minutes_summary/pages/loginpage.dart';
import 'package:minutes_summary/pages/signuppage.dart';
import 'dart:io';

final storage = FlutterSecureStorage();
String? value;
//import 'auth.dart'; // Import the authentication logic
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  value = await storage.read(key: 'uid');
  // Initialize Hive
  // Open a box to store data
// Initialize Hive with the app's document directory
  // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: value != null ? Homepage() : LoginScreen(),
      debugShowCheckedModeBanner: false, // Initial screen
    );
  }
}
