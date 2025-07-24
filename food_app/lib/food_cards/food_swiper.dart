// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:food_app/food_cards/food_card.dart'; // FoodItem and FoodCard definition
import 'package:food_app/food_cards/food_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodCardSwiperScreen extends StatefulWidget {
  const FoodCardSwiperScreen({super.key});

  @override
  State<FoodCardSwiperScreen> createState() => _FoodCardSwiperScreenState();
}

class _FoodCardSwiperScreenState extends State<FoodCardSwiperScreen> {
  final CardSwiperController controller = CardSwiperController();
  List<FoodItem> foodItems = [];
  bool isLoading = true;
  bool allCardsSwiped = false;

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    final url = Uri.parse(
      'http://127.0.0.1:5000/cards',
    ); // Use LAN IP if on real device
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          foodItems = data.map((e) => FoodItem.fromJson(e)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

@override
Widget build(BuildContext context) {
  if (isLoading) return const Center(child: CircularProgressIndicator());

  return Column(
    children: [
      Expanded(
        child: allCardsSwiped
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('All cards swiped!'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                          allCardsSwiped = false;
                        });
                        await fetchFoodItems();
                      },
                      child: const Text('Reload Cards'),
                    ),
                  ],
                ),
              )
            : CardSwiper(
                controller: controller,
                cardsCount: foodItems.length,
                isLoop: true, // <-- Enable looping here
                onSwipe: (index, _, dir) {
                  final item = foodItems[index];
                  final direction = dir == CardSwiperDirection.right
                      ? "right"
                      : "left";

                  http.post(
                    Uri.parse('http://127.0.0.1:5000/swipe'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'card_id': index,
                      'direction': direction,
                      'name': item.name,
                    }),
                  );

                  return true;
                },
                onEnd: () => setState(() => allCardsSwiped = true),
                //change this for design
                cardBuilder: (context, index, _, __) {
                  final item = foodItems[index];
                  return FoodCard(
                    foodItem: item,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodDetailScreen(foodItem: item),
                      ),
                    ),
                  );
                },
              ),
      ),
      if (!allCardsSwiped)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () => controller.swipe(CardSwiperDirection.left),
                backgroundColor: Colors.red,
                child: const Icon(Icons.close),
              ),
              FloatingActionButton(
                onPressed: () => controller.undo(),
                backgroundColor: Colors.grey,
                child: const Icon(Icons.undo),
              ),
              FloatingActionButton(
                onPressed: () => controller.swipe(CardSwiperDirection.right),
                backgroundColor: Colors.green,
                child: const Icon(Icons.favorite),
              ),
            ],
          ),
        ),
    ],
  );
}
}
