// Import the new detail screen

// FoodItem class should now be in food_card.dart, so it's removed from here if it was present.
import 'package:flutter/material.dart';
import 'food_cards/food_swiper.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tinder-like Food Swiper'),
        ),
        body: const FoodCardSwiperScreen(),
      ),
    );
  }
}