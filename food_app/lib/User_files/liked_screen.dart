import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class LikedRestaurantsScreen extends StatefulWidget {
  final String username;

  const LikedRestaurantsScreen({Key? key, required this.username})
      : super(key: key);

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
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/liked_restaurants?username=${widget.username}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        likedRestaurants = jsonDecode(response.body);
      });
    } else {
      print('Failed to load liked restaurants');
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
                  subtitle: Text(
                    'Liked on ${_formatTimestamp(restaurant['likedTimestamp'] ?? '')}',
                  ),
                  leading: restaurant['imageUrl'] != null
                      ? Image.network(
                          restaurant['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.restaurant),
                  onTap: () {
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
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (restaurant['description'] != null)
                                  Text(
                                    restaurant['description'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                const SizedBox(height: 8),
                                if (restaurant['addressLink'] != null)
                                  GestureDetector(
                                    onTap: () async {
                                      final url = Uri.parse(restaurant['addressLink']);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      }
                                    },
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
                  },
                );
              },
            ),
    );
  }
}
