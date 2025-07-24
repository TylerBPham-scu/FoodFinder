// lib/food_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Needed for launching map link on detail screen
import 'package:food_app/food_card.dart'; // Import FoodItem definition

class FoodDetailScreen extends StatelessWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({
    super.key,
    required this.foodItem,
  });

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(foodItem.name),
        backgroundColor: Colors.deepOrange, // A nice color for the app bar
      ),
      body: SingleChildScrollView( // Allows content to scroll if it's too long
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero animation for image transition
            Hero(
              tag: 'foodImage-${foodItem.name}', // Unique tag for Hero animation
              child: Image.network(
                foodItem.imageUrl,
                width: double.infinity, // Take full width
                height: 300, // Fixed height for the image
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    foodItem.description,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                      height: 1.5, // Line height
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Restaurant Details:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          foodItem.restaurantAddress,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await _launchUrl(foodItem.addressLink, context);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.map, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Open in Maps',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // You can add more details here, e.g., reviews, phone number, etc.
                  // Example:
                  // const Text('Opening Hours: 9 AM - 10 PM', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}