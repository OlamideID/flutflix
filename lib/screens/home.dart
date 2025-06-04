import 'dart:js' as js; // Only works on web

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/movie_model.dart';
import 'package:netflix/models/popular_series.dart';
import 'package:netflix/models/top_rated.dart';
import 'package:netflix/models/trending.dart';
import 'package:netflix/models/up_coming_model.dart';
import 'package:netflix/screens/movie_details.dart';
import 'package:netflix/screens/series_detailscreen.dart';
import 'package:netflix/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
    movieData = apiService.fetchMovies();
    upcomingMovies = apiService.upComingMovies();
    topRated = apiService.topRatedMovies();
    trending = apiService.trendingMovies();
    popularTVSeries = apiService.popularSeries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Image.asset('assets/download.jpeg', height: 50),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, size: 27),
                    color: Colors.white,
                  ),
                  const Icon(Icons.download_sharp, color: Colors.white),
                  const SizedBox(width: 10),
                  const Icon(Icons.cast, color: Colors.white),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  _buildMenuButton('TV Shows'),
                  const SizedBox(width: 8),
                  _buildMenuButton('Movies'),
                  const SizedBox(width: 8),
                  MaterialButton(
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.white30),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
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

                            BoxFit getBoxFit(double width) {
                              if (width < 600) return BoxFit.cover;
                              return BoxFit.fitWidth;
                            }

                            return Stack(
                              children: [
                                // Background movie image
                                Positioned.fill(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      print('movie id ${movie.id}');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return MovieDetailsScreen(
                                              movieId: movie.id,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            "$imageUrl${movie.posterPath}",
                                          ),
                                          fit: getBoxFit(screenWidth),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Buttons overlaid at bottom
                                Positioned(
                                  left: 30,
                                  right: 30,
                                  bottom: 30,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          minimumSize: const Size(150, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final url = getVideoUrl(
                                            movie.id.toString(),
                                          );
                                          await openUrl(url);
                                        },
                                        icon: const Icon(
                                          Icons.play_arrow,
                                          color: Colors.black,
                                          size: 30,
                                        ),
                                        label: const Text(
                                          'Play',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.grey.shade800,
                                          minimumSize: const Size(150, 50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          // Optional: Add to My List
                                        },
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        label: const Text(
                                          'My List',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
            ),
            SizedBox(height: 30),
            movieTypes(
              future: trending,
              movieType: 'Trending Movies',
              isReverse: false,
            ),
            movieTypes(
              future: upcomingMovies,
              movieType: 'Upcoming Movies',
              isReverse: false,
            ),
            seriesTypes(
              future: popularTVSeries,
              seriesType: 'popular Tv Series',
              isReverse: false,
            ),
            movieTypes(
              future: topRated,
              movieType: 'Top Rated Movies',
              isReverse: false,
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Padding movieTypes({
    required Future future,
    required String movieType,
    bool isReverse = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movieType,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180, // Increased height for better visibility
            child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final movies = snapshot.data?.results ?? [];
                  if (isReverse) {
                    movies.reversed.toList();
                  }

                  return ListView.builder(
                    reverse: isReverse,
                    scrollDirection: Axis.horizontal,
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return MovieDetailsScreen(movieId: movie.id);
                                },
                              ),
                            );
                            print(movie.adult);
                            print(movie.id);
                            print(movie.title);
                            print(movie.video);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: "$imageUrl${movie.posterPath}",
                              width: 120,
                              height: 180,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[800],
                                    width: 120,
                                    height: 180,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey[800],
                                    width: 120,
                                    height: 180,
                                    child: const Icon(Icons.error),
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding seriesTypes({
    required Future<PopularTvSeries?> future, // Specify the exact type
    required String seriesType,
    bool isReverse = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            seriesType,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: FutureBuilder<PopularTvSeries?>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final seriesList = snapshot.data!.results;

                  if (seriesList.isEmpty) {
                    return const Center(child: Text('No series found'));
                  }

                  if (isReverse) {
                    seriesList.reversed.toList();
                  }

                  return ListView.builder(
                    reverse: isReverse,
                    scrollDirection: Axis.horizontal,
                    itemCount: seriesList.length,
                    itemBuilder: (context, index) {
                      final series = seriesList[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );

                            try {
                              final apiService = ApiService();
                              final seriesDetails = await apiService
                                  .seriesDetail(series.id);

                              Navigator.of(context).pop();

                              if (seriesDetails == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Series details not available',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          SeriesDetailsScreen(id: series.id),
                                ),
                              );
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: "$imageUrl${series.posterPath}",
                              width: 120,
                              height: 180,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[800],
                                    width: 120,
                                    height: 180,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey[800],
                                    width: 120,
                                    height: 180,
                                    child: const Icon(Icons.error),
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title) {
    return MaterialButton(
      onPressed: () {},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white30),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String getVideoUrl(String movieId) {
    return 'https://vidsrc.icu/embed/movie/$movieId';
  }

  Future<void> openUrl(String url) async {
    if (kIsWeb) {
      js.context.callMethod('open', [url]);
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
