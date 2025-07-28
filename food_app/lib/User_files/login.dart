import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_app/main.dart';
import 'package:http/http.dart' as http;
//import 'package:food_app/main.dart'; // update if needed
//import 'package:food_app/food_cards/food_swiper.dart';
//import 'package:food_app/old_code/food_swiper_old.dart';
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
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
Future<void> _handleLogin() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserItem(
        id: data['id'] ?? '', // Optional: if your backend returns id
        name: data['name'],
        avatarUrl: data['avatarUrl'] ?? '',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(username: username),
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

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        setState(() => _error = "Registration successful. Please log in.");
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Registration failed';
        setState(() => _error = error);
      }
    } catch (e) {
      setState(() => _error = 'Registration failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login / Register")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text('Login'),
                      ),
                      TextButton(
                        onPressed: _handleRegister,
                        child: const Text('Register'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
