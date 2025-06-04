import 'package:flutter/material.dart';
import 'package:netflix/components/movie_list.dart';
import 'package:netflix/components/series_section.dart';
import 'package:netflix/screens/home.dart';

class MovieSection extends StatelessWidget {
  final Future future;
  final String sectionTitle;
  final bool isReverse;

  const MovieSection({
    super.key,
    required this.future,
    required this.sectionTitle,
    this.isReverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: sectionTitle),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                } else if (snapshot.hasError) {
                  return ErrorDisplay(error: snapshot.error.toString());
                } else if (snapshot.hasData) {
                  final movies = snapshot.data?.results ?? [];
                  
                  return MovieList(
                    movies: movies,
                    isReverse: isReverse,
                  );
                } else {
                  return const NoDataDisplay();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}