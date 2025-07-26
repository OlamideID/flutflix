import 'dart:io';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:netflix/constants/colors.dart';
import 'package:netflix/screens/home.dart';
import 'package:netflix/screens/my_list.dart';
import 'package:netflix/screens/search.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      NetflixHome(
        search: () {
          _onTabChange(1); // ✅ Switch to Search screen
        },
      ),
      const SearchScreen(),
      MyListScreen(),
    ];
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildWebNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: GNav(
            rippleColor: const Color(0xFF9B5DE5).withOpacity(0.2),
            hoverColor: const Color(0xFF9B5DE5).withOpacity(0.1),
            haptic: true,
            gap: 8,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 300),
            tabBackgroundColor: const Color(0xFF9B5DE5).withOpacity(0.15),
            color: Colors.grey.shade500,
            activeColor: const Color(0xFF9B5DE5),
            iconSize: 26,
            backgroundColor: Colors.transparent,
            selectedIndex: _selectedIndex,
            onTabChange: _onTabChange,
            tabs: const [
              GButton(icon: Iconsax.home5, text: 'Home'),
              GButton(icon: Iconsax.search_normal, text: 'Search'),
              GButton(icon: Icons.my_library_add, text: 'My List'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidNavBar() {
    return CurvedNavigationBar(
      index: _selectedIndex,
      height: 60,
      backgroundColor: Colors.transparent,
      color: Colors.black87,
      buttonBackgroundColor: Colors.redAccent,
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      onTap: _onTabChange,
      items: const [
        Icon(Iconsax.home, size: 26, color: Colors.white),
        Icon(Iconsax.search_normal, size: 26, color: Colors.white),
        Icon(Icons.photo_library, size: 26, color: Colors.white),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorss.scaffoldBg,
      body: _screens[_selectedIndex],
      bottomNavigationBar:
          kIsWeb
              ? _buildWebNavBar()
              : Platform.isAndroid
              ? _buildAndroidNavBar()
              : _buildWebNavBar(),
    );
  }
}
