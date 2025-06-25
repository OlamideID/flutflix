import 'package:flutter/material.dart';

class NetflixAppBar extends StatelessWidget {
  const NetflixAppBar({super.key, required this.search});
  final Function search;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Image.asset('assets/download.jpeg', height: 50),
          const Spacer(),
          IconButton(
            onPressed: () {
              search();
            },
            icon: const Icon(Icons.search, size: 27),
            color: Colors.white,
          ),
          const Icon(Icons.download_sharp, color: Colors.white),
          const SizedBox(width: 10),
          const Icon(Icons.cast, color: Colors.white),
        ],
      ),
    );
  }
}
