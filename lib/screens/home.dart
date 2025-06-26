import 'package:flutter/material.dart';
import 'package:netflix/components/home_app_bar.dart';
import 'package:netflix/components/home_menu_bar.dart';
import 'package:netflix/components/movies/featured_carousel.dart';
import 'package:netflix/components/movies/movie_section.dart';
import 'package:netflix/components/series/series_section.dart';
import 'package:netflix/providers/providers.dart';

class NetflixHome extends StatefulWidget {
  const NetflixHome({super.key, required this.search});

  final VoidCallback search;

  @override
  State<NetflixHome> createState() => _NetflixHomeState();
}

class _NetflixHomeState extends State<NetflixHome> {
  final GlobalKey trendingMoviesKey = GlobalKey();
  final GlobalKey popularTvKey = GlobalKey();

  void scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetflixAppBar(search: widget.search),
              NetflixMenuBar(
                tv: () => scrollTo(popularTvKey),
                movies: () => scrollTo(trendingMoviesKey),
              ),
              const SizedBox(height: 10),
              const FeaturedMovieCarousel(),
              const SizedBox(height: 30),
              MovieSection(
                key: trendingMoviesKey,
                provider: trendingMoviesProvider,
                sectionTitle: 'Trending Movies',
              ),
              MovieSection(
                provider: upcomingMoviesProvider,
                sectionTitle: 'Upcoming Movies',
              ),
              SeriesSection(
                
                key: popularTvKey,
                provider: popularSeriesProvider,
                sectionTitle: 'Popular TV Series',
              ),
              MovieSection(
                provider: topRatedMoviesProvider,
                sectionTitle: 'Top Rated Movies',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
