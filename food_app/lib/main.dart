import 'package:flutter/material.dart';
import 'package:food_app/User_files/login.dart';
import 'food_cards/food_swiper_refactored.dart';
import 'Upload/image_picker.dart';
import 'User_files/liked_screen_refactored.dart';
import 'User_files/interest_refactored.dart';
import 'User_files/user_info_refactored.dart';
import 'friends/friends.dart'; // Adjust path if needed

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

class MainScreen extends StatefulWidget {
  final String username;
  const MainScreen({super.key, required this.username});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<FoodCardSwiperScreenState> swiperKey = GlobalKey<FoodCardSwiperScreenState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      FoodCardSwiperScreen(key: swiperKey, username: widget.username),
      const ImagePickerScreen(),
      LikedRestaurantsScreen(username: widget.username),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToLocationScreen() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationScreen(
          username: widget.username,
          swiperKey: swiperKey,
        ),
      ),
    );
  }

  void _navigateToProfileScreen() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(username: widget.username),
      ),
    );
  }

  void _navigateToFriendPage() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendPage(username: widget.username),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Welcome, ${widget.username}!'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Start Search'),
              onTap: _navigateToLocationScreen,
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: _navigateToProfileScreen,
            ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Friends'),
            onTap: _navigateToFriendPage,
          ),

          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Swiper'),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Liked'),
        ],
      ),
    );
  }
}
