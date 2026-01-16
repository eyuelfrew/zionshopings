import 'package:flutter/material.dart';
import 'package:zionshopings/screens/category_listing_screen.dart';
import 'package:zionshopings/screens/home_screen.dart';
import 'package:zionshopings/screens/profile_screen.dart';
import 'package:zionshopings/screens/wishlist_screen.dart';
import 'package:zionshopings/widgets/zion_bottom_navbar.dart';

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  _MainAppShellState createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CategoryListingScreen(), // Updated screen
    WishlistScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // This allows the body to extend behind the navbar
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: ZionBottomNavbar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
