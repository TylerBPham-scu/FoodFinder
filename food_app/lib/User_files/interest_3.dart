import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:food_app/food_cards/food_swiper_refactored.dart';

class LocationScreen extends StatefulWidget {
  final String username;
  final GlobalKey<FoodCardSwiperScreenState> swiperKey;

  const LocationScreen({
    super.key,
    required this.username,
    required this.swiperKey,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LatLng? _userLocation;
  final List<String> foodOptions = [
    'Spicy',
    'Vegan',
    'Gluten-Free',
    'Sweet',
    'Seafood',
    'BBQ',
  ];
  final Set<String> selectedOptions = {};
  List<String> allFriends = [];
  Set<String> selectedFriends = {};
  String sessionId = '';

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    try {
      final response = await http.get(Uri.parse(
          'http://127.0.0.1:5000/get_friend_requests?username=${widget.username}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          allFriends = List<String>.from(data['friends'] ?? []);
        });
      }
    } catch (e) {
      _showSnackBar("Error fetching friends: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar("Location services are disabled.");
        Navigator.pop(context);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar("Location permissions are denied.");
          Navigator.pop(context);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar("Location permissions are permanently denied.");
        Navigator.pop(context);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      await _sendLocationToServer(position.latitude, position.longitude);

      widget.swiperKey.currentState?.fetchFoodItems();

      if (context.mounted) Navigator.pop(context);

      _showSnackBar('Updated nearby food cards.');
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showSnackBar("Error: $e");
    }
  }

  Future<void> _sendLocationToServer(double lat, double lng) async {
    final url = Uri.parse('http://127.0.0.1:5000/update_location');
    final body = jsonEncode({
      'username': widget.username,
      'latitude': lat,
      'longitude': lng,
      'preferences': selectedOptions.toList(),
      'session_id': sessionId,
      'friends_in_session': selectedFriends.toList(),
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      _showSnackBar('Failed: ${response.body}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildOptionButton(String option) {
    final isSelected = selectedOptions.contains(option);

    return ChoiceChip(
      label: Text(option),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          if (isSelected) {
            selectedOptions.remove(option);
          } else {
            selectedOptions.add(option);
          }
        });
      },
      selectedColor: Colors.blueAccent,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _buildMap() {
    if (_userLocation == null) {
      return const Text("Press 'Start Search' to get your location.");
    }

    return SizedBox(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: _userLocation!,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: _userLocation!,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Location')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildMap(),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: foodOptions.map(_buildOptionButton).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: "Session ID (optional)"),
              onChanged: (val) => sessionId = val,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: allFriends.map((friend) {
                final selected = selectedFriends.contains(friend);
                return FilterChip(
                  label: Text(friend),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      selected ? selectedFriends.remove(friend) : selectedFriends.add(friend);
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('Start Search'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
