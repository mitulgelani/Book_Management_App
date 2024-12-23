import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:async';
import 'package:minutes_summary/authentication/auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'auth.dart'; // Import authentication service

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference users = firestore.collection('users');
    Map<String, dynamic> data = {'name': name, 'phone': phone};

    await Firebase.initializeApp();

    String userId;

    if (email.isNotEmpty && password.isNotEmpty) {
      final user = await _authService.signUp(email, password);
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        userId = currentUser.uid;
        print('User ID: $userId');
      }

      if (user != null) {
        try {
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          final CollectionReference users = firestore.collection('users');
          print('-------------------------------mlakns--->');
          print(currentUser?.uid);
          print('-------------------------------mlakns--->');
          // More detailed error catching

          await users
              .doc(currentUser?.uid)
              .collection('profile')
              .doc(currentUser?.uid)
              .set(data)
              .then((_) {
            print('Document successfully written');
          }).catchError((error) {
            print('Error writing document: $error');
            print('Error type: ${error.runtimeType}');
            if (error is FirebaseException) {
              print('Firebase Error Code: ${error.code}');
              print('Firebase Error Message: ${error.message}');
            }
          });
        } catch (e) {
          print('Unexpected error: $e');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup Successful')),
        );

        Navigator.pop(context);
        // Navigate back to login screen
      } else {
        // Signup failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.23,
                  screenHeight * 0.3, screenWidth * 0.25, 0),
              child: const Text(
                'Sign-Up',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  TextField(
                    controller: phoneController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.35,
                          vertical: screenHeight * 0.015),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 173, 162, 63),

                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(19.0)),
                      minimumSize: const Size(100, 40), //////// HERE
                    ),
                    onPressed: signUp,
                    child: const Text('Register'),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, screenHeight * 0.04, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Bootstrap
                                .arrow_left, // Beautiful arrow icon from icons_plus
                            color: Colors.black,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
