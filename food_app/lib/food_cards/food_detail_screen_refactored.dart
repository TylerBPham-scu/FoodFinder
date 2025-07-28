import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:food_app/food_cards/food_card_refactored.dart'; // Ensure this is the correct import

class FoodDetailScreen extends StatelessWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  Future<void> _launchUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust sizes based on screen size
    final imageHeight = screenHeight * 0.3; // Adjust image height based on screen height
    final textSize = screenWidth < 600 ? 24.0 : 32.0; // Smaller text for smaller screens
    final descriptionSize = screenWidth < 600 ? 14.0 : 18.0; // Adjust description text size

    return Scaffold(
      appBar: AppBar(
        title: Text(foodItem.name),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'foodImage-${foodItem.name}',
              child: Image.network(
                foodItem.imageUrl,
                height: imageHeight, // Dynamic image height
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth < 600 ? 8.0 : 16.0), // Adjust padding based on screen size
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    foodItem.description,
                    style: TextStyle(fontSize: descriptionSize, color: Colors.black87, height: 1.5),
                  ),
                  const Divider(height: 30),
                  const Text(
                    'Restaurant Details:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          foodItem.restaurantAddress,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _launchUrl(foodItem.addressLink, context),
                    child: const Row(
                      children: [
                        Icon(Icons.map, color: Colors.blue),
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
