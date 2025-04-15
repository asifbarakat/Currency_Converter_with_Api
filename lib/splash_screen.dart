import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart'; // Import your home screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomeScreen after 3 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home()),
      );
    });
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo here
            Image.asset(
              'assets/icons/logo.png',
              height: 180,
              width: 180,
            ),
            const SizedBox(height: 20),
            // --- Styled Title ---
            Text(
              'Currency Converter',
              style: TextStyle(
                fontSize: 28,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5, // Adds spacing between letters
                shadows: [ // Adds a subtle shadow for depth
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            // --- Styled Subtitle ---
            Text(
              'Developed by Asif Barakat Chowdhury',
              style: TextStyle(
                fontSize: 16, // Slightly smaller than title
                fontWeight: FontWeight.w500, // Medium weight
                fontStyle: FontStyle.italic, // Italicize
                color: Colors.white.withOpacity(0.9), // Slightly transparent
                letterSpacing: 0.8, // Less spacing than title
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}