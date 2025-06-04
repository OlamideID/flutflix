import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:netflix/constants/colors.dart';
import 'package:netflix/screens/home.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const NetflixHome(),
    const Scaffold(), // Replace with your actual Search screen
    const Scaffold(
      backgroundColor: Colors.amber,
    ), // Replace with actual Hot News screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorss.scaffoldBg,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colorss.scaffoldBg,
          border: const Border(
            top: BorderSide(color: Colors.white12, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: GNav(
              rippleColor: Colorss.whiteSecondary.withOpacity(0.2),
              hoverColor: Colors.white10,
              haptic: true,
              gap: 6,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              duration: const Duration(milliseconds: 250),
              tabBackgroundColor: Colors.white.withOpacity(0.06),
              color: Colorss.whiteSecondary,
              activeColor: Colorss.whitePrimary,
              iconSize: 24,
              backgroundColor: Colors.transparent,
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              tabs: const [
                GButton(icon: Iconsax.home5, text: 'Home'),
                GButton(icon: Iconsax.search_normal, text: 'Search'),
                GButton(icon: Icons.photo_library, text: 'Hot News'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
