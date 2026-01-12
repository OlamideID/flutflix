// widgets/netflix_menu_bar.dart
import 'package:flutter/material.dart';
import 'package:netflix/features/home/widgets/home_menu_button.dart';

class NetflixMenuBar extends StatelessWidget {
  const NetflixMenuBar({super.key, required this.tv, required this.movies});
  final Function tv;
  final Function movies;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          NetflixMenuButton(
            title: 'TV Shows',
            onPressed: () {
              tv();
            },
          ),
          const SizedBox(width: 8),
          NetflixMenuButton(
            title: 'Movies',
            onPressed: () {
              movies();
            },
          ),
          const SizedBox(width: 8),
          MaterialButton(
            onPressed: () {
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
