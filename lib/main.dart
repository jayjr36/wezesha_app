// main.dart
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import './homescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Wallet Master',
        home: AnimatedSplashScreen(
            duration: 3000,
            splash: 'assets/logo.png',
            nextScreen: const HomeScreen(),
            splashTransition: SplashTransition.fadeTransition,
            backgroundColor: const Color.fromARGB(61, 107, 58, 18)));
  }
}
