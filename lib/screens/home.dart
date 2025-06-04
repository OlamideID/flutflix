// netflix_home.dart
import 'package:flutter/material.dart';
import 'package:netflix/components/featured_carousel.dart';
import 'package:netflix/components/home_app_bar.dart';
import 'package:netflix/components/home_menu_bar.dart';
import 'package:netflix/components/movie_section.dart';
import 'package:netflix/components/series_section.dart';
import 'package:netflix/services/api_service.dart';
import 'package:netflix/models/movie_model.dart';
import 'package:netflix/models/popular_series.dart';
import 'package:netflix/models/top_rated.dart';
import 'package:netflix/models/trending.dart';
import 'package:netflix/models/up_coming_model.dart';

// Widgets

class NetflixHome extends StatefulWidget {
  const NetflixHome({super.key});

  @override
  State<NetflixHome> createState() => _NetflixHomeState();
}

class _NetflixHomeState extends State<NetflixHome> {
  final ApiService apiService = ApiService();
  late Future<Movie?> movieData;
  late Future<UpcomingMovie?> upcomingMovies;
  late Future<Toprated?> topRated;
  late Future<Trending?> trending;
  late Future<PopularTvSeries?> popularTVSeries;

  @override
  void initState() {
    super.initState();
    _initializeFutures();
  }

  void _initializeFutures() {
    movieData = apiService.fetchMovies();
    upcomingMovies = apiService.upComingMovies();
    topRated = apiService.topRatedMovies();
    trending = apiService.trendingMovies();
    popularTVSeries = apiService.popularSeries();
  }

  @override
  Widget build(BuildContext context) {
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
            FeaturedMovieCarousel(movieData: movieData),
            const SizedBox(height: 30),
            MovieSection(
              future: trending,
              sectionTitle: 'Trending Movies',
            ),
            MovieSection(
              future: upcomingMovies,
              sectionTitle: 'Upcoming Movies',
            ),
            SeriesSection(
              future: popularTVSeries,
              sectionTitle: 'Popular TV Series',
            ),
            MovieSection(
              future: topRated,
              sectionTitle: 'Top Rated Movies',
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}




// widgets/featured_movie_actions.dart

// widgets/netflix_action_button.dart

// widgets/movie_section.dart


// widgets/series_section.dart


// widgets/common/loading_indicator.dart
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// widgets/common/error_display.dart
class ErrorDisplay extends StatelessWidget {
  final String error;

  const ErrorDisplay({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error: $error'));
  }
}

// widgets/common/no_data_display.dart
class NoDataDisplay extends StatelessWidget {
  final String message;

  const NoDataDisplay({
    super.key,
    this.message = 'No data available',
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

// widgets/movie_list.dart

// widgets/series_list.dart

// widgets/movie_card.dart

// widgets/series_card.dart

// widgets/common/image_placeholder.dart
