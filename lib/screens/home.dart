import 'package:flutter/material.dart';
import 'package:netflix/components/home_app_bar.dart';
import 'package:netflix/components/home_menu_bar.dart';
import 'package:netflix/components/movies/featured_carousel.dart';
import 'package:netflix/components/movies/movie_section.dart';
import 'package:netflix/components/series/series_section.dart';
import 'package:netflix/providers/providers.dart';

class NetflixHome extends StatelessWidget {
  const NetflixHome({super.key, required this.search});

  final VoidCallback search;

  @override
  Widget build(BuildContext context) {
    final popularTvKey = GlobalKey();
    final trendingMoviesKey = GlobalKey();

    void scrollTo(GlobalKey key) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(child: NetflixAppBar(search: search)),

            SliverToBoxAdapter(
              child: NetflixMenuBar(
                tv: () => scrollTo(popularTvKey),
                movies: () => scrollTo(trendingMoviesKey),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            const SliverToBoxAdapter(child: FeaturedMovieCarousel()),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),

            SliverToBoxAdapter(
              key: trendingMoviesKey,
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
              key: popularTvKey,
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
          ],
        ),
      ),
    );
  }
}
