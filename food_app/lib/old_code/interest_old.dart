import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationScreen extends StatefulWidget {
  final String username;
  const LocationScreen({super.key, required this.username});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _locationMessage = "Select prefrences and start your search";

  final List<String> foodOptions = ['Spicy', 'Vegan', 'Gluten-Free', 'Sweet', 'Seafood', 'BBQ'];
  final Set<String> selectedOptions = {};

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Location services are disabled.";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Location permissions are permanently denied.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _locationMessage =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });

    await _sendLocationToServer(position.latitude, position.longitude);
  }

  Future<void> _sendLocationToServer(double lat, double lng) async {
    final url = Uri.parse('http://127.0.0.1:5000/update_location');
    final body = jsonEncode({
      'username': widget.username,
      'latitude': lat,
      'longitude': lng,
      'preferences': selectedOptions.toList(),
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location and preferences sent!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(_locationMessage),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: foodOptions.map(_buildOptionButton).toList(),
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
