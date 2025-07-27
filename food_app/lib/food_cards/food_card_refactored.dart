// food_card_refactored.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Define the FoodItem class
class FoodItem {
  final String name;
  final String imageUrl;
  final String description;
  final String restaurantAddress;
  final String addressLink;
  final List<String> cuisines; // Added cuisines field

  FoodItem({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.restaurantAddress,
    required this.addressLink,
    required this.cuisines,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      restaurantAddress: json['restaurantAddress'],
      addressLink: json['addressLink'],
      cuisines: List<String>.from(json['cuisines'] ?? []),
    );
  }
}

// Define the FoodCard widget
class FoodCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback? onTap;
  final double? height; // Add height parameter to adjust card height

  const FoodCard({
    super.key,
    required this.foodItem,
    this.onTap,
    this.height, // Make height an optional parameter
  });

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
    final cardPadding = screenWidth < 600 ? 8.0 : 16.0; // Smaller padding for smaller screens
    final textSize = screenWidth < 600 ? 18.0 : 22.0; // Smaller text for smaller screens
    final descriptionSize = screenWidth < 600 ? 14.0 : 16.0; // Smaller text for descriptions on smaller screens

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'foodImage-${foodItem.name}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                        child: Image.network(
                          foodItem.imageUrl,
                          fit: BoxFit.cover,
                          height: imageHeight, // Dynamic image height based on screen height
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
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey,
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                            ),
                          ),
                        ),
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
            
            // Text and description section
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(cardPadding), // Dynamic padding based on screen size
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.name,
                      style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      foodItem.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: descriptionSize, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cuisine: ${foodItem.cuisines.join(', ')}',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text('📍 ${foodItem.restaurantAddress}', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _launchUrl(foodItem.addressLink, context),
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
  }
}
