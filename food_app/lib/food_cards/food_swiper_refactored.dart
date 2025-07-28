import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'food_card_refactored.dart';
import 'food_detail_screen_refactored.dart';
import 'package:http/http.dart' as http;

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    print(screenWidth);
    print(screenHeight);
    final bool isTabletOrLarger = screenWidth > 700;

    final buttonSize = isTabletOrLarger ? 50.0 : 30.0;
    final cardHeight = isTabletOrLarger ? screenHeight * 0.5 : screenHeight * 0.4;
    final padding = screenWidth < 600 ? 8.0 : 16.0;

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
                      height: cardHeight,
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
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'dislike',
                  onPressed: () => controller.swipe(CardSwiperDirection.left),
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: buttonSize),
                ),
                FloatingActionButton(
                  heroTag: 'undo',
                  onPressed: () => controller.undo(),
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.undo, size: buttonSize),
                ),
                FloatingActionButton(
                  heroTag: 'like',
                  onPressed: () => controller.swipe(CardSwiperDirection.right),
                  backgroundColor: Colors.green,
                  child: Icon(Icons.favorite, size: buttonSize),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
