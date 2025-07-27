import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'food_card_refactored.dart';
import 'food_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';  // To use kIsWeb


class FoodCardSwiperScreen extends StatefulWidget {
  final String username;

  const FoodCardSwiperScreen({super.key, required this.username});

  @override
  FoodCardSwiperScreenState createState() => FoodCardSwiperScreenState();
}

class FoodCardSwiperScreenState extends State<FoodCardSwiperScreen> {
  final CardSwiperController controller = CardSwiperController();
  List<FoodItem> foodItems = [];
  bool isLoading = true;
  bool allCardsSwiped = false;
  final String timestamp = DateTime.now().toIso8601String();

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:5000/cards?username=${widget.username}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          foodItems = data.map((e) => FoodItem.fromJson(e)).toList();
          isLoading = false;
          allCardsSwiped = false;
        });
      } else {
        setState(() {
          foodItems = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        foodItems = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsive design
    final screenWidth = MediaQuery.of(context).size.width; // Get screen width
    final screenHeight = MediaQuery.of(context).size.height; // Get screen height
    final isWeb = kIsWeb; // Check if the app is running on web

    // Adjust sizes based on screen size (example values, adjust as needed)
    final buttonSize = isWeb ? 50.0 : (screenWidth * 0.12); // Buttons bigger on web
    final cardHeight = isWeb ? screenHeight * 0.5 : screenHeight * 0.4; // Larger cards on mobile

    // Adjust padding based on screen width (example values, adjust as needed)
    final padding = screenWidth < 600 ? 8.0 : 16.0;  // Smaller padding for small devices, larger padding for bigger screens

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: (foodItems.isNotEmpty && !allCardsSwiped)
              ? CardSwiper(
                  controller: controller,
                  cardsCount: foodItems.length,
                  onSwipe: (index, _, dir) {
                    final item = foodItems[index];
                    final direction = dir == CardSwiperDirection.right ? "right" : "left";

                    http.post(
                      Uri.parse('http://127.0.0.1:5000/swipe'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'card_id': index,
                        'direction': direction,
                        'name': item.name,
                        'user': widget.username,
                        'timestamp': timestamp,
                      }),
                    );
                    return true;
                  },
                  onEnd: () => setState(() => allCardsSwiped = true),
                  cardBuilder: (context, index, _, __) {
                    final item = foodItems[index];
                    return FoodCard(
                      foodItem: item,
                      height: cardHeight, // Set card height dynamically
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodDetailScreen(foodItem: item),
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: Text('No restaurants found')),
        ),
        if (foodItems.isNotEmpty && !allCardsSwiped)
          Padding(
            // Adjust padding based on screen width (Responsive padding)
            padding: EdgeInsets.symmetric(horizontal: padding),  // Adjust padding for smaller screens
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'dislike',
                  onPressed: () => controller.swipe(CardSwiperDirection.left),
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.close,
                    size: buttonSize, // Adjust button size based on screen width
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'undo',
                  onPressed: () => controller.undo(),
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.undo,
                    size: buttonSize, // Adjust button size based on screen width
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'like',
                  onPressed: () => controller.swipe(CardSwiperDirection.right),
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.favorite,
                    size: buttonSize, // Adjust button size based on screen width
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
