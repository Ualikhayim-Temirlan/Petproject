import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_application_1/screens/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepOrange.shade900,
              Colors.orange.shade700,
              Colors.yellow.shade600,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/logo.png',
                width: 120,
                height: 120,
              ),
              SizedBox(height: 20),
              Text(
                '451 Gradus',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Compete. Rise. Be the best',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}