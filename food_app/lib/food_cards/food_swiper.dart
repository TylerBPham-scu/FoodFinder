import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:food_app/food_cards/food_card.dart'; // FoodItem and FoodCard definition
import 'package:food_app/food_cards/food_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodCardSwiperScreen extends StatefulWidget {
  final String username;

  const FoodCardSwiperScreen({super.key, required this.username});

  @override
  State<FoodCardSwiperScreen> createState() => _FoodCardSwiperScreenState();
}

class _FoodCardSwiperScreenState extends State<FoodCardSwiperScreen> {
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
    final url = Uri.parse('http://127.0.0.1:5000/cards?username=${widget.username}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          foodItems = data.map((e) => FoodItem.fromJson(e)).toList();
          isLoading = false;
          allCardsSwiped = false;  // reset swiped flag when loading new data
        });
      } else {
        setState(() {
          foodItems = [];
          isLoading = false;
          allCardsSwiped = false;
        });
      }
    } catch (e) {
      print('Fetch error: $e');
      setState(() {
        foodItems = [];
        isLoading = false;
        allCardsSwiped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FoodDetailScreen(foodItem: item),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: allCardsSwiped
                      ? Column(
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
                        )
                      : const Text(
                          'There are no restaurants near you.',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                ),
        ),
        if (foodItems.isNotEmpty && !allCardsSwiped)
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
