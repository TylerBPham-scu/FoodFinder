import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LikedRestaurantsScreen extends StatefulWidget {
  final String username; // Pass this in from login

  const LikedRestaurantsScreen({super.key, required this.username});

  @override
  State<LikedRestaurantsScreen> createState() => _LikedRestaurantsScreenState();
}

class _LikedRestaurantsScreenState extends State<LikedRestaurantsScreen> {
  late Future<List<dynamic>> likedRestaurantsFuture;

  @override
  void initState() {
    super.initState();
    likedRestaurantsFuture = fetchLikedRestaurants(widget.username);
  }

  Future<List<dynamic>> fetchLikedRestaurants(String username) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/liked_restaurants'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load liked restaurants');
    }
  }

  Future<void> removeLikedRestaurant(String? restaurantName) async {
    if (restaurantName == null) return; // safety check

    final response = await http.post(
      Uri.parse('http://localhost:5000/remove_liked_restaurant'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'restaurant': restaurantName,
      }),
    );

    if (response.statusCode == 200) {
      // Refresh the liked restaurants list after removal
      setState(() {
        likedRestaurantsFuture = fetchLikedRestaurants(widget.username);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove liked restaurant')),
        );
      }
    }
  }

  // Helper to format ISO timestamp to readable format
  String _formatTimestamp(String isoTimestamp) {
    try {
      final dt = DateTime.parse(isoTimestamp).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.month}/${dt.day}/${dt.year} $hour:$minute';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liked Restaurants")),
      body: FutureBuilder<List<dynamic>>(
        future: likedRestaurantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No liked restaurants found.'));
          }

          final restaurants = snapshot.data!;

          // Sort alphabetically by restaurant name A-Z
          restaurants.sort((a, b) {
            final nameA = (a['name'] ?? '').toString().toLowerCase();
            final nameB = (b['name'] ?? '').toString().toLowerCase();
            return nameA.compareTo(nameB);
          });

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: restaurant['imageUrl'] != null
                      ? Image.network(
                          restaurant['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.restaurant),
                  title: Text(restaurant['name'] ?? 'Unknown'),
                  subtitle: Text(restaurant['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // keep trailing compact
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: Text(
                          restaurant['likedTimestamp'] != null
                              ? _formatTimestamp(restaurant['likedTimestamp'])
                              : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          removeLikedRestaurant(restaurant['name']);
                        },
                        tooltip: 'Remove from liked',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
