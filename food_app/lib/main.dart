import 'package:flutter/material.dart';
import 'package:food_app/User_files/login.dart';
import 'food_cards/food_swiper.dart';
import 'Upload/image_picker.dart';
import 'User_files/login.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),  // Start at LoginScreen
    );
  }
}