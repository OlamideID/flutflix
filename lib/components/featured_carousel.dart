import 'package:flutter/material.dart';
import 'package:netflix/components/featured_movie_card.dart';
import 'package:netflix/models/movie_model.dart';

class FeaturedMovieCarousel extends StatelessWidget {
  final Future<Movie?> movieData;

  const FeaturedMovieCarousel({
    super.key,
    required this.movieData,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 600,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: FutureBuilder<Movie?>(
          future: movieData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final movies = snapshot.data?.results ?? [];

              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: PageView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return FeaturedMovieCard(
                      movie: movie,
                      screenWidth: screenWidth,
                    );
                  },
                ),
              );
            } else {
              return const Center(child: Text('Something went wrong'));
            }
          },
        ),
      ),
    );
  }
}
