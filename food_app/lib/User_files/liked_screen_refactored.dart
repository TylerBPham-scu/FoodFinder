import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class LikedRestaurantsScreen extends StatefulWidget {
  final String username;

  const LikedRestaurantsScreen({Key? key, required this.username}) : super(key: key);

  @override
  _LikedRestaurantsScreenState createState() => _LikedRestaurantsScreenState();
}

class _LikedRestaurantsScreenState extends State<LikedRestaurantsScreen> {
  List<dynamic> likedRestaurants = [];

  @override
  void initState() {
    super.initState();
    fetchLikedRestaurants();
  }

  Future<void> fetchLikedRestaurants() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/liked_restaurants?username=${widget.username}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          likedRestaurants = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load liked restaurants');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime parsed = DateTime.parse(timestamp);
      return '${parsed.month}/${parsed.day}/${parsed.year} ${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid timestamp';
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _confirmDelete(BuildContext context, dynamic restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Liked?'),
        content: Text('Are you sure you want to remove "${restaurant['name']}" from liked restaurants?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Remove'),
            onPressed: () async {
              Navigator.of(context).pop();
              await _removeLikedRestaurant(restaurant['name']);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _removeLikedRestaurant(String name) async {
    final url = Uri.parse('http://127.0.0.1:5000/remove_liked_restaurant');
    final body = jsonEncode({
      'username': widget.username,
      'restaurant': name,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          likedRestaurants.removeWhere((r) => r['name'] == name);
        });
        _showSnackBar('Removed "$name" from liked restaurants.');
      } else {
        _showSnackBar('Failed to remove "$name": ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liked Restaurants')),
      body: likedRestaurants.isEmpty
          ? const Center(child: Text('No liked restaurants found.'))
          : ListView.builder(
              itemCount: likedRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = likedRestaurants[index];
                return ListTile(
                  title: Text(restaurant['name'] ?? 'Unknown'),
                  subtitle: Text('Liked on ${_formatTimestamp(restaurant['likedTimestamp'] ?? '')}'),
                  leading: restaurant['imageUrl'] != null
                      ? Image.network(
                          restaurant['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.restaurant);
                          },
                        )
                      : const Icon(Icons.restaurant),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, restaurant),
                  ),
                  onTap: () => _showRestaurantDetailDialog(context, restaurant),
                );
              },
            ),
    );
  }

  void _showRestaurantDetailDialog(BuildContext context, dynamic restaurant) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(12),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (restaurant['imageUrl'] != null)
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.network(
                      restaurant['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  restaurant['name'] ?? 'Restaurant Details',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (restaurant['description'] != null)
                  Text(restaurant['description'], style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                if (restaurant['addressLink'] != null)
                  GestureDetector(
                    onTap: () => _launchUrl(restaurant['addressLink']),
                    child: const Text(
                      'View on Map',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
