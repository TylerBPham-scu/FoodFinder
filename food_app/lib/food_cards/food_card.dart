import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
/*

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

class FoodCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback? onTap;

  const FoodCard({
    super.key,
    required this.foodItem,
    this.onTap,
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
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        margin: EdgeInsets.zero,
        child: Column(
          children: [
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
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(foodItem.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      foodItem.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cuisine: ${foodItem.cuisines.join(', ')}',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text('📍 ${foodItem.restaurantAddress}',
                        style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _launchUrl(foodItem.addressLink, context),
                      child: const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue, size: 18),
                          SizedBox(width: 4),
                          Text('View on Map',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              )),
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
*/