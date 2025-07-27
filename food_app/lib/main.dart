import 'package:flutter/material.dart';
import 'package:food_app/User_files/login.dart';
import 'food_cards/food_swiper.dart';
import 'Upload/image_picker.dart';
import 'User_files/location.dart';
import 'User_files/liked_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}

// MainScreen with BottomNavigationBar
class MainScreen extends StatefulWidget {
  final String username;
  const MainScreen({super.key, required this.username});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Pass username to pages that need it
    _pages = <Widget>[
      FoodCardSwiperScreen(username: widget.username),
      ImagePickerScreen(),
      LocationScreen(username: widget.username),
      LikedRestaurantsScreen(username: widget.username), // <-- Added here
      // Add more pages here if needed
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${widget.username}!')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Add this line
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Swiper'),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Upload'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Liked'),
        ],
      ),
    );
  }
}
