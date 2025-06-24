import 'package:flutter/material.dart';
import 'package:netflix/components/movies/featured_carousel.dart';
import 'package:netflix/components/home_app_bar.dart';
import 'package:netflix/components/home_menu_bar.dart';
import 'package:netflix/components/movies/movie_section.dart';
import 'package:netflix/components/series/series_section.dart';
import 'package:netflix/providers/providers.dart';

class NetflixHome extends StatelessWidget {
  const NetflixHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO: Add refresh logic here
          },
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Netflix App Bar
              const SliverToBoxAdapter(child: NetflixAppBar()),

              // Netflix Menu Bar
              const SliverToBoxAdapter(child: NetflixMenuBar()),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // Featured Movie Carousel - wrap in SliverToBoxAdapter since it's not a sliver widget
              const SliverToBoxAdapter(child: FeaturedMovieCarousel()),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),

              // Movie Sections and Series Section
              SliverToBoxAdapter(
                child: MovieSection(
                  provider: trendingMoviesProvider,
                  sectionTitle: 'Trending Movies',
                ),
              ),
              SliverToBoxAdapter(
                child: MovieSection(
                  provider: upcomingMoviesProvider,
                  sectionTitle: 'Upcoming Movies',
                ),
              ),
              SliverToBoxAdapter(
                child: SeriesSection(
                  provider: popularSeriesProvider,
                  sectionTitle: 'Popular TV Series',
                ),
              ),
              SliverToBoxAdapter(
                child: MovieSection(
                  provider: topRatedMoviesProvider,
                  sectionTitle: 'Top Rated Movies',
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),
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
