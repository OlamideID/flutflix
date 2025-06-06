import 'package:flutter/material.dart';
import 'package:netflix/components/featured_carousel.dart';
import 'package:netflix/components/home_app_bar.dart';
import 'package:netflix/components/home_menu_bar.dart';
import 'package:netflix/components/movie_section.dart';
import 'package:netflix/components/series_section.dart';
import 'package:netflix/services/api_service.dart';

class NetflixHome extends StatelessWidget {
  const NetflixHome({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const NetflixAppBar(),
            const NetflixMenuBar(),
            const SizedBox(height: 10),
            FeaturedMovieCarousel(movieData: apiService.fetchMovies()),
            const SizedBox(height: 30),
            MovieSection(
              future: apiService.trendingMovies(),
              sectionTitle: 'Trending Movies',
            ),
            MovieSection(
              future: apiService.upComingMovies(),
              sectionTitle: 'Upcoming Movies',
            ),
            SeriesSection(
              future: apiService.popularSeries(),
              sectionTitle: 'Popular TV Series',
            ),
            MovieSection(
              future: apiService.topRatedMovies(),
              sectionTitle: 'Top Rated Movies',
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorDisplay extends StatelessWidget {
  final String error;

  const ErrorDisplay({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error: $error'));
  }
}

class NoDataDisplay extends StatelessWidget {
  final String message;

  const NoDataDisplay({super.key, this.message = 'No data available'});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}
