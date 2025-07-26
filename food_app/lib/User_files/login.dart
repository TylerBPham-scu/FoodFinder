import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:food_app/main.dart'; // update if needed
import 'package:food_app/food_cards/food_swiper.dart';
class UserItem {
  final String id;
  final String name;
  final String avatarUrl;

  UserItem({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final username = _usernameController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserItem(
          id: data['id'],
          name: data['name'],
          avatarUrl: data['avatarUrl'],
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FoodCardSwiperScreen(user: user),
          ),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Login failed';
        setState(() => _error = error);
      }
    } catch (e) {
      setState(() => _error = 'Login failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Enter your username'),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
