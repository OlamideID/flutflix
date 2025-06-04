import 'package:flutter/material.dart';
import 'package:netflix/components/cards/movie_card.dart';

class MovieList extends StatelessWidget {
  final List movies;
  final bool isReverse;

  const MovieList({
    super.key,
    required this.movies,
    required this.isReverse,
  });

  @override
  Widget build(BuildContext context) {
    final displayMovies = isReverse ? movies.reversed.toList() : movies;

    return ListView.builder(
      reverse: isReverse,
      scrollDirection: Axis.horizontal,
      itemCount: displayMovies.length,
      itemBuilder: (context, index) {
        final movie = displayMovies[index];
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: MovieCard(movie: movie),
        );
      },
    );
  }
}
