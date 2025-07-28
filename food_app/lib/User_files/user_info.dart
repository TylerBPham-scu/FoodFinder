import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserProfileScreen extends StatefulWidget {
  final String username;

  const UserProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String password = '';
  String avatarUrl = '';
  List<String> preferences = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/login?username=${widget.username}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        password = data['password'] ?? '';
        avatarUrl = data['avatarUrl'] ?? '';
        preferences = List<String>.from(data['preferences'] ?? []);
        loading = false;
      });
    } else {
      print("Failed to fetch user data");
      setState(() => loading = false);
    }
  }

  Future<void> updateProfile() async {
    final updatedData = {
      'password': password,
      'avatarUrl': avatarUrl,
    };

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/update_profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'updatedData': updatedData,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: widget.username,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        enabled: false,
                      ),
                    ),
                    TextFormField(
                      initialValue: password,
                      decoration: const InputDecoration(labelText: 'Password'),
                      onChanged: (val) => password = val,
                    ),
                    TextFormField(
                      initialValue: avatarUrl,
                      decoration: const InputDecoration(labelText: 'Avatar URL'),
                      onChanged: (val) => avatarUrl = val,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      children: preferences.map((pref) => Chip(label: Text(pref))).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateProfile,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
