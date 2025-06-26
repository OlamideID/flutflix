import 'package:flutter/material.dart';
import 'package:netflix/components/movies/movie_card.dart';

class MovieList extends StatelessWidget {
  final List movies;
  final bool isReverse;

  const MovieList({super.key, required this.movies, required this.isReverse});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          "No movies available",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final displayMovies = isReverse ? movies.reversed.toList() : movies;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: displayMovies.length,
      cacheExtent: 1000,
      itemBuilder: (context, index) {
        final movie = displayMovies[index];
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 10),
          child: MovieCard(movie: movie),
        );
      },
    );
  }
}
