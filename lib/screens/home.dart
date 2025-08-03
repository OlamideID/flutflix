import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/components/home/widgets/home_app_bar.dart';
import 'package:netflix/components/home/widgets/home_menu_bar.dart';
import 'package:netflix/components/movies/widgets/featured_carousel.dart';
import 'package:netflix/components/movies/widgets/movie_section.dart';
import 'package:netflix/components/series/widgets/series_section.dart';
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

  bool showMovies = true; // toggle state

  // Random recommendations
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
    final randomIds = [
      1399, // Game of Thrones
      1396, // Breaking Bad
      66732, // Stranger Things
      94997, // House of the Dragon
      85552, // Euphoria
      60735, // The Flash
      1418, // The Big Bang Theory
      456, // The Simpsons
      1402, // The Walking Dead
      1408, // House
      37854, // Suits
      46261, // Fargo
      72879, // The Boys
      88396, // The Falcon and the Winter Soldier
      85271, // WandaVision
      95557, // Invincible
      63174, // Lucifer
      71712, // The Good Place
      60059, // Better Call Saul
      61889, // Marvel's Daredevil
      1429, // Attack on Titan
      1434, // Family Guy
      18165, // The Vampire Diaries
      1622, // Supernatural
      4614, // NCIS
      82856, // The Mandalorian
      119051, // Wednesday
      111453, // The Bear
      92830, // Squid Game
      100088, // The Witcher
      136315, // The Last of Us
      92783, // Loki
      210401, // Gen V
      114695, // Heartstopper
      83867, // The Umbrella Academy
      87108, // Chernobyl
      2316, // The Office
      1412, // Arrow
      1390, // American Horror Story
      76479, // The Boys
      1399, // Peaky Blinders
      68542, // The Crown
      79126, // Money Heist
      60625, // Rick and Morty
      1421, // Modern Family
      1416, // Grey's Anatomy
      1413, // American Dad!
      1409, // Sherlock
      1431, // Homeland
    ];
    randomSeriesId =
        randomIds[DateTime.now().millisecondsSinceEpoch % randomIds.length];
    lastRandomUpdate = now;

    // Schedule next update
    Future.delayed(Duration(hours: 6), () {
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
