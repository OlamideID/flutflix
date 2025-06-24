import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/components/movies/featured_movie_card.dart';
import 'package:netflix/providers/providers.dart';

class FeaturedMovieCarousel extends ConsumerWidget {
  const FeaturedMovieCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    int itemsToShow;
    if (screenWidth >= 1200) {
      itemsToShow = 3; // Desktop
    }
    //else if (screenWidth >= 750) {
    //   itemsToShow = 2; // Tablet
    // }
    else {
      itemsToShow = 1; // Mobile
    }

    final movieAsyncValue = ref.watch(fetchMoviesProvider);

    final width = MediaQuery.of(context).size.width;
    print(width);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 600,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: movieAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (movieData) {
            final movies = movieData?.results ?? [];

            if (movies.isEmpty) {
              return const Center(child: Text('No movies found'));
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CarouselSlider.builder(
                itemCount: movies.length,
                itemBuilder: (context, index, realIndex) {
                  final movie = movies[index];
                  return FeaturedMovieCard(
                    movie: movie,
                    screenWidth: screenWidth / itemsToShow,
                  );
                },
                options: CarouselOptions(
                  height: 600,
                  viewportFraction: 1 / itemsToShow,
                  enableInfiniteScroll: true,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
