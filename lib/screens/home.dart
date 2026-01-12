import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/features/home/widgets/home_app_bar.dart';
import 'package:netflix/features/home/widgets/home_menu_bar.dart';
import 'package:netflix/features/movies/widgets/featured_carousel.dart';
import 'package:netflix/features/movies/widgets/movie_section.dart';
import 'package:netflix/features/series/widgets/series_section.dart';
import 'package:netflix/constants/randoms.dart';
import 'package:netflix/providers/providers.dart';

class NetflixHome extends ConsumerStatefulWidget {
  const NetflixHome({super.key, required this.search});
  final VoidCallback search;

  @override
  ConsumerState<NetflixHome> createState() => _NetflixHomeState();
}

class _NetflixHomeState extends ConsumerState<NetflixHome> {
  final GlobalKey trendingMoviesKey = GlobalKey();
  final GlobalKey popularTvKey = GlobalKey();

  bool showMovies = true;

  int randomSeriesId = 1399;
  DateTime? lastRandomUpdate;

  @override
  void initState() {
    super.initState();
    _updateRandomSeries();
  }

  void _updateRandomSeries() {
    final now = DateTime.now();
    if (!mounted ||
        (lastRandomUpdate != null &&
            now.difference(lastRandomUpdate!).inHours < 6)) {
      return;
    }

    randomSeriesId = AppData.randomSeriesIds[
        DateTime.now().millisecondsSinceEpoch % AppData.randomSeriesIds.length];
    lastRandomUpdate = now;

    Future.delayed(const Duration(hours: 6), () {
      if (mounted) _updateRandomSeries();
    });
  }

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

  Widget buildToggleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => setState(() => showMovies = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: showMovies ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Movies",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => setState(() => showMovies = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !showMovies ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "TV Series",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMovieSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        MovieSection(
          provider: topRatedMoviesProvider,
          sectionTitle: 'Top Rated Movies',
        ),
      ],
    );
  }

  Widget buildTvSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeriesSection(
          key: popularTvKey,
          provider: popularSeriesProvider,
          sectionTitle: 'Popular TV Series',
        ),
        SeriesSection(
          provider: airingTodaySeriesProvider,
          sectionTitle: 'Airing Today',
        ),
        SeriesSection(
          provider: recommendedSeriesProvider(randomSeriesId),
          sectionTitle: 'Random Picks for You',
        ),
      ],
    );
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
              buildToggleButton(),
              const SizedBox(height: 10),
              if (showMovies) buildMovieSections() else buildTvSections(),
            ],
          ),
        ),
      ),
    );
  }
}