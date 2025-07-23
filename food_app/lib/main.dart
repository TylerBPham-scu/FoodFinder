import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:url_launcher/url_launcher.dart';

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
          title: const Text('Food Swiper'),
        ),
        body: const FoodCardSwiperScreen(),
      ),
    );
  }
}

class FoodItem {
  final String name;
  final String imageUrl;
  final String description;
  final String restaurantAddress;
  final String addressLink;

  FoodItem({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.restaurantAddress,
    required this.addressLink,
  });
}

class FoodCardSwiperScreen extends StatefulWidget {
  const FoodCardSwiperScreen({super.key});

  @override
  State<FoodCardSwiperScreen> createState() => _FoodCardSwiperScreenState();
}

class _FoodCardSwiperScreenState extends State<FoodCardSwiperScreen> {
  final CardSwiperController controller = CardSwiperController();
  bool allCardsSwiped = false; // New state variable to track if cards are done

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
      throw Exception('Could not launch $url');
    }
  }

  final List<FoodItem> foodItems = [
    FoodItem(
      name: 'Spaghetti Carbonara',
      imageUrl: 'https://via.placeholder.com/400x400/FF5733/FFFFFF?text=Carbonara',
      description: 'Classic Italian pasta dish with eggs, hard cheese, cured pork, and black pepper.',
      restaurantAddress: '123 Pasta Lane, Rome',
      addressLink: 'https://maps.app.goo.gl/YourActualCarbonaraMapLink', // REPLACE with actual map link
    ),
    FoodItem(
      name: 'Sushi Platter',
      imageUrl: 'https://via.placeholder.com/400x400/3366FF/FFFFFF?text=Sushi',
      description: 'A delightful assortment of fresh sushi and sashimi.',
      restaurantAddress: '456 Sushi Blvd, Tokyo',
      addressLink: 'https://maps.app.goo.gl/YourActualSushiMapLink', // REPLACE with actual map link
    ),
    FoodItem(
      name: 'Indian Curry',
      imageUrl: 'https://via.placeholder.com/400x400/33FF57/FFFFFF?text=Curry',
      description: 'A rich and aromatic curry, perfect with rice or naan.',
      restaurantAddress: '789 Spice Street, Delhi',
      addressLink: 'https://maps.app.goo.gl/YourActualCurryMapLink', // REPLACE with actual map link
    ),
    FoodItem(
      name: 'Mexican Tacos',
      imageUrl: 'https://via.placeholder.com/400x400/FFFF33/000000?text=Tacos',
      description: 'Delicious tacos with various fillings and fresh salsa.',
      restaurantAddress: '101 Taco Road, Mexico City',
      addressLink: 'https://maps.app.goo.gl/YourActualTacosMapLink', // REPLACE with actual map link
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Removed manual cardWidth/cardHeight calculation and rely on CardSwiper's padding for size.
    // The card will expand to fill the space within the CardSwiper's padding.

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
                          // Reset the state to show cards again (useful for demonstration)
                          setState(() {
                            allCardsSwiped = false;
                            // Optionally, if you modify the foodItems list (e.g., remove items),
                            // you might need to re-initialize or reset the controller here.
                            // For this example, since foodItems is final, just setting
                            // allCardsSwiped to false is enough.
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
                    // If you undo after all cards were swiped, make sure the message is gone
                    if (allCardsSwiped) {
                      setState(() {
                        allCardsSwiped = false;
                      });
                    }
                    return true;
                  },
                  // Use horizontal and vertical padding to define the card size and center it
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  // New: onEnd callback to detect when all cards are swiped
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

                    return GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped on ${foodItem.name} for more info!')),
                        );
                        print('Tapped on ${foodItem.name}');
                      },
                      child: Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: EdgeInsets.zero, // Keep margin zero, padding property handles spacing
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                                      child: Image.network(
                                        foodItem.imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey,
                                            child: const Center(
                                              child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withOpacity(0.3),
                                      alignment: Alignment.center,
                                      child: Text(
                                        foodItem.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      foodItem.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      foodItem.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '📍 ${foodItem.restaurantAddress}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () async {
                                        await _launchUrl(foodItem.addressLink);
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.location_on, color: Colors.blue, size: 18),
                                          SizedBox(width: 4),
                                          Text(
                                            'View on Map',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Buttons are only shown if not all cards are swiped
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