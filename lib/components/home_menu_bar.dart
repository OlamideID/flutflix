

// widgets/netflix_menu_bar.dart
import 'package:flutter/material.dart';
import 'package:netflix/components/home_menu_button.dart';

class NetflixMenuBar extends StatelessWidget {
  const NetflixMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          NetflixMenuButton(title: 'TV Shows', onPressed: () {}),
          const SizedBox(width: 8),
          NetflixMenuButton(title: 'Movies', onPressed: () {}),
          const SizedBox(width: 8),
          MaterialButton(
            onPressed: () {
              // Handle categories
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.white30),
            ),
            child: const Row(
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
