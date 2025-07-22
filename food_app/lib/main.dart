import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart'; // Import the package

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

class FoodItem {
  final String name;
  final String imageUrl;
  final String description;

  FoodItem({required this.name, required this.imageUrl, required this.description});
}

class FoodCardSwiperScreen extends StatefulWidget {
  const FoodCardSwiperScreen({super.key});

  @override
  State<FoodCardSwiperScreen> createState() => _FoodCardSwiperScreenState();
}

class _FoodCardSwiperScreenState extends State<FoodCardSwiperScreen> {
  final CardSwiperController controller = CardSwiperController();

  // Our list of food items
  final List<FoodItem> foodItems = [
    FoodItem(
      name: 'Spaghetti Carbonara',
      imageUrl: 'https://via.placeholder.com/400x400/FF5733/FFFFFF?text=Carbonara',
      description: 'Classic Italian pasta dish with eggs, hard cheese, cured pork, and black pepper.',
    ),
    FoodItem(
      name: 'Sushi Platter',
      imageUrl: 'https://via.placeholder.com/400x400/3366FF/FFFFFF?text=Sushi',
      description: 'A delightful assortment of fresh sushi and sashimi.',
    ),
    FoodItem(
      name: 'Indian Curry',
      imageUrl: 'https://via.placeholder.com/400x400/33FF57/FFFFFF?text=Curry',
      description: 'A rich and aromatic curry, perfect with rice or naan.',
    ),
    FoodItem(
      name: 'Mexican Tacos',
      imageUrl: 'https://via.placeholder.com/400x400/FFFF33/000000?text=Tacos',
      description: 'Delicious tacos with various fillings and fresh salsa.',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the total screen width
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the horizontal margin (5% on each side, so 10% total)
    final double horizontalMarginPercentage = 0.05; // 5%
    final double totalHorizontalMargin = screenWidth * (horizontalMarginPercentage * 2);

    // Calculate the width and height of the card
    final double cardWidth = screenWidth - totalHorizontalMargin;
    // We'll make the card slightly taller than a perfect square to leave room for text below the image.
    // Adjust this value as needed to fit your design.
    final double cardHeight = cardWidth * 1.2; // Example: 20% taller than its width

    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: controller,
            cardsCount: foodItems.length,
            numberOfCardsDisplayed: 2, // Shows the current card and a glimpse of the next
            // Updated onSwipe signature for flutter_card_swiper ^7.0.0
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
              return true; // Return true to allow the swipe, false to prevent it
            },
            // Updated onUndo signature for flutter_card_swiper ^7.0.0
            onUndo: (int? previousIndex, int index, CardSwiperDirection direction) {
              print('Undone $direction from index $index (previously $previousIndex)');
              return true;
            },
            padding: const EdgeInsets.symmetric(vertical: 20.0), // Padding around the swiper itself
            cardBuilder: (
              BuildContext context,
              int index,
              int horizontalThresholdPercentage,
              int verticalThresholdPercentage,
            ) {
              final FoodItem foodItem = foodItems[index];

              return GestureDetector(
                onTap: () {
                  // Handle tap for more info
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped on ${foodItem.name} for more info!')),
                  );
                  print('Tapped on ${foodItem.name}');
                  // You would typically navigate to a detail screen here
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => FoodDetailScreen(foodItem: foodItem),
                  //   ),
                  // );
                },
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.zero, // CardSwiper handles the spacing
                  child: Container(
                    width: cardWidth,
                    height: cardHeight, // Use the calculated cardHeight
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3, // Image takes up 3 parts of the height
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
                                          // Corrected property names for ImageChunkEvent
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey, // Fallback color for error
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
                                  color: Colors.black.withOpacity(0.3), // Dark overlay for text readability
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Image Placeholder', // This text can be removed if you have actual images
                                    style: TextStyle(
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
                          flex: 1, // Text details take up 1 part of the height
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
                                  maxLines: 2, // Limit description to 2 lines
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700], // Changed from pink to grey for better contrast
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Example buttons to manually swipe (optional)
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