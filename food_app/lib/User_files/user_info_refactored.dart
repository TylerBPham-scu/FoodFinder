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
  bool loading = true;

  String password = '';
  String avatarUrl = '';
  List<String> preferences = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
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
        _showSnackBar("Failed to fetch user data.");
        setState(() => loading = false);
      }
    } catch (e) {
      _showSnackBar("Error fetching user data.");
      setState(() => loading = false);
    }
  }

  Future<void> _updateProfile() async {
    final updatedData = {
      'password': password,
      'avatarUrl': avatarUrl,
    };

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/update_profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': widget.username,
          'updatedData': updatedData,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Profile updated successfully.');
      } else {
        _showSnackBar('Failed to update profile.');
      }
    } catch (e) {
      _showSnackBar('Error updating profile.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildUserForm(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic sizing
    final double basePadding = screenWidth < 600 ? 16.0 : 32.0;
    final double baseFontSize = screenWidth < 600 ? 14.0 : 18.0;
    final double titleFontSize = screenWidth < 600 ? 22.0 : 28.0;
    final double buttonFontSize = screenWidth < 600 ? 16.0 : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: basePadding, vertical: 24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'User Profile',
              style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            TextFormField(
              initialValue: widget.username,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              enabled: false,
              style: TextStyle(fontSize: baseFontSize),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => password = val,
              style: TextStyle(fontSize: baseFontSize),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: avatarUrl,
              decoration: const InputDecoration(
                labelText: 'Avatar URL',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => avatarUrl = val,
              style: TextStyle(fontSize: baseFontSize),
            ),
            const SizedBox(height: 24),

            Text('Preferences:', style: TextStyle(fontSize: baseFontSize + 2, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: preferences.map((pref) => Chip(label: Text(pref, style: TextStyle(fontSize: baseFontSize)))).toList(),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('Save Changes', style: TextStyle(fontSize: buttonFontSize)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _buildUserForm(context),
    );
  }
}
