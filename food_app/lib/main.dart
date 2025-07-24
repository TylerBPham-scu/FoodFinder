// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:food_app/food_card.dart'; // FoodItem and FoodCard definition
import 'package:food_app/food_detail_screen.dart'; // Import the new detail screen

// FoodItem class should now be in food_card.dart, so it's removed from here if it was present.

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

class FoodCardSwiperScreen extends StatefulWidget {
  const FoodCardSwiperScreen({super.key});

  @override
  State<FoodCardSwiperScreen> createState() => _FoodCardSwiperScreenState();
}

class _FoodCardSwiperScreenState extends State<FoodCardSwiperScreen> {
  final CardSwiperController controller = CardSwiperController();
  bool allCardsSwiped = false;

  final List<FoodItem> foodItems = [
    FoodItem(
      name: 'Spaghetti Carbonara',
      imageUrl: 'https://via.placeholder.com/400x400/FF5733/FFFFFF?text=Carbonara',
      description: 'Classic Italian pasta dish with eggs, hard cheese, cured pork, and black pepper. A timeless dish originating from Rome, known for its rich and creamy texture without using cream. It relies on the emulsification of egg yolks, Pecorino Romano cheese, cured guanciale or pancetta, and black pepper. Best served immediately upon preparation.',
      restaurantAddress: '123 Pasta Lane, Rome',
      addressLink: 'https://www.google.com/maps/search/?api=1&query=123+Pasta+Lane,+Rome', // REAL map link example
    ),
    FoodItem(
      name: 'Sushi Platter',
      imageUrl: 'https://via.placeholder.com/400x400/3366FF/FFFFFF?text=Sushi',
      description: 'A delightful assortment of fresh sushi and sashimi, prepared by expert chefs. Features a variety of nigiri, maki, and fresh raw fish slices. Accompanied by soy sauce, wasabi, and pickled ginger for a complete experience. Perfect for a light yet satisfying meal.',
      restaurantAddress: '456 Sushi Blvd, Tokyo',
      addressLink: 'https://www.google.com/maps/search/?api=1&query=456+Sushi+Blvd,+Tokyo', // REAL map link example
    ),
    FoodItem(
      name: 'Indian Curry',
      imageUrl: 'https://via.placeholder.com/400x400/33FF57/FFFFFF?text=Curry',
      description: 'A rich and aromatic curry, slow-cooked to perfection with a blend of exotic spices and tender meat/vegetables. This dish embodies the vibrant flavors of traditional Indian cuisine, offering a comforting and flavorful experience. Best enjoyed with fragrant basmati rice or warm naan bread.',
      restaurantAddress: '789 Spice Street, Delhi',
      addressLink: 'https://www.google.com/maps/search/?api=1&query=789+Spice+Street,+Delhi', // REAL map link example
    ),
    FoodItem(
      name: 'Mexican Tacos',
      imageUrl: 'https://via.placeholder.com/400x400/FFFF33/000000?text=Tacos',
      description: 'Delicious corn tortillas filled with various fillings like seasoned meat, fresh vegetables, cilantro, and onions. Topped with a squeeze of lime and spicy salsa, these tacos offer an authentic taste of Mexican street food. A perfect blend of savory, fresh, and zesty flavors.',
      restaurantAddress: '101 Taco Road, Mexico City',
      addressLink: 'https://www.google.com/maps/search/?api=1&query=101+Taco+Road,+Mexico+City', // REAL map link example
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: allCardsSwiped
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                      const SizedBox(height: 20),
                      const Text(
                        'All cards swiped!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No more food suggestions for now.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            allCardsSwiped = false;
                            // Optionally, reset the swiper state if needed more comprehensively
                            // controller.next(); // or similar if you want to explicitly reset
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Restart Swiper'),
                      ),
                    ],
                  ),
                )
              : CardSwiper(
                  controller: controller,
                  cardsCount: foodItems.length,
                  numberOfCardsDisplayed: 2,
                  onSwipe: (int index, int? previousIndex, CardSwiperDirection direction) {
                    final String foodName = foodItems[index].name;
                    if (direction == CardSwiperDirection.right) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Swiped right! Interested in $foodName')),
                      );
                      print('Swiped right! Interested in $foodName');
                    } else if (direction == CardSwiperDirection.left) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Swiped left! Not interested in $foodName')),
                      );
                      print('Swiped left! Not interested in $foodName');
                    } else {
                      print('Swiped $direction for $foodName');
                    }
                    return true;
                  },
                  onUndo: (int? previousIndex, int index, CardSwiperDirection direction) {
                    print('Undone $direction from index $index (previously $previousIndex)');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Undid swipe on ${foodItems[index].name}')),
                    );
                    if (allCardsSwiped) {
                      setState(() {
                        allCardsSwiped = false;
                      });
                    }
                    return true;
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  onEnd: () {
                    print('All cards have been swiped!');
                    setState(() {
                      allCardsSwiped = true;
                    });
                  },
                  cardBuilder: (
                    BuildContext context,
                    int index,
                    int horizontalThresholdPercentage,
                    int verticalThresholdPercentage,
                  ) {
                    final FoodItem foodItem = foodItems[index];
                    return FoodCard(
                      foodItem: foodItem,
                      onTap: () {
                        // Navigate to the detail screen when the card is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailScreen(foodItem: foodItem),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        if (!allCardsSwiped)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'leftButton',
                  onPressed: () {
                    controller.swipe(CardSwiperDirection.left);
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: 'undoButton',
                  onPressed: () {
                    controller.undo();
                  },
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(Icons.undo, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: 'rightButton',
                  onPressed: () {
                    controller.swipe(CardSwiperDirection.right);
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
              ],
            ),
          ),
      ],
    );
  }
}