import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FriendPage extends StatefulWidget {
  final String username;

  const FriendPage({super.key, required this.username});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final TextEditingController _friendController = TextEditingController();
  Map<String, dynamic> friends = {};
  List<String> incomingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriendsAndRequests();
  }

  Future<void> fetchFriendsAndRequests() async {
    setState(() => isLoading = true);
    try {
      // Get friends
      final friendsRes = await http.get(
        Uri.parse('http://127.0.0.1:5000/get_friends?username=${widget.username}'),
      );

      // Get friend requests
      final requestsRes = await http.get(
        Uri.parse('http://127.0.0.1:5000/get_friend_requests?username=${widget.username}'),
      );

      if (friendsRes.statusCode == 200 && requestsRes.statusCode == 200) {
        setState(() {
          friends = jsonDecode(friendsRes.body);
          final requests = jsonDecode(requestsRes.body);
          incomingRequests = List<String>.from(requests['incomingRequests'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showSnackBar("Failed to load friends or requests");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Error: $e");
    }
  }

  Future<void> sendFriendRequest() async {
    final friendUsername = _friendController.text.trim();
    if (friendUsername.isEmpty) return;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/send_friend_request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'target_username': friendUsername, // FIXED KEY
      }),
    );

    if (response.statusCode == 200) {
      _showSnackBar("Friend request sent!");
      _friendController.clear();
    } else {
      _showSnackBar("Error: ${response.body}");
    }
  }

  Future<void> acceptFriend(String fromUsername) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/accept_friend_request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'from_user': fromUsername, // FIXED KEY
      }),
    );

    if (response.statusCode == 200) {
      _showSnackBar("Friend request accepted");
      fetchFriendsAndRequests();
    } else {
      _showSnackBar("Error: ${response.body}");
    }
  }

  Future<void> removeFriend(String friendUsername) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/remove_friend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': widget.username,
        'friend_username': friendUsername,
      }),
    );

    if (response.statusCode == 200) {
      _showSnackBar("Friend removed.");
      fetchFriendsAndRequests();
    } else {
      _showSnackBar("Error: ${response.body}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends & Requests')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _friendController,
                          decoration: const InputDecoration(labelText: 'Friend username'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: sendFriendRequest,
                        child: const Text('Send Request'),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (incomingRequests.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Incoming Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ...incomingRequests.map((username) {
                          return ListTile(
                            title: Text(username),
                            trailing: ElevatedButton(
                              onPressed: () => acceptFriend(username),
                              child: const Text('Accept'),
                            ),
                          );
                        }),
                        const Divider(height: 30),
                      ],
                    ),
                  const Text('Your Friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: friends.isEmpty
                        ? const Text('No friends found.')
                        : ListView(
                            children: friends.keys.map((friendUsername) {
                              return ListTile(
                                title: Text(friendUsername),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => removeFriend(friendUsername),
                                ),
                              );
                            }).toList(),
                          ),
                  )
                ],
              ),
            ),
    );
  }
}
