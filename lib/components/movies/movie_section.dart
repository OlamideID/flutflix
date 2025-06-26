import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/helpers/helpers.dart';
import 'package:netflix/screens/movie_details.dart';

class MovieSection extends ConsumerWidget {
  final String sectionTitle;
  final bool isReverse;
  final FutureProvider provider;

  const MovieSection({
    super.key,
    required this.provider,
    required this.sectionTitle,
    this.isReverse = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMovies = ref.watch(provider);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220, // Increased height for better visuals
            child: asyncMovies.when(
              loading: () => const _MovieLoadingCarousel(),
              error: (e, _) => ErrorDisplay(error: e.toString()),
              data: (data) {
                final movies = data?.results ?? [];
                if (movies.isEmpty) {
                  return const Center(
                    child: Text(
                      "No movies found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return _MovieCarousel(movies: movies, isReverse: isReverse);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieCarousel extends StatelessWidget {
  final List movies;
  final bool isReverse;

  const _MovieCarousel({required this.movies, required this.isReverse});

  @override
  Widget build(BuildContext context) {
    final displayMovies = isReverse ? movies.reversed.toList() : movies;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: displayMovies.length,
      itemBuilder: (context, index) {
        return _MovieCarouselCard(movie: displayMovies[index]);
      },
    );
  }
}

class _MovieCarouselCard extends StatelessWidget {
  final dynamic movie;

  const _MovieCarouselCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToDetails(context),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with shadow and rounded corners
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    // Image Background
                    Positioned.fill(
                      child:
                          movie.posterPath != null
                              ? _buildMovieImage(movie.posterPath!)
                              : _buildErrorPlaceholder(),
                    ),

                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                            stops: const [0.7, 1],
                          ),
                        ),
                      ),
                    ),

                    // Play Button
                    // Positioned.fill(
                    //   child: Center(
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.black.withOpacity(0.5),
                    //         shape: BoxShape.circle,
                    //       ),
                    //       padding: const EdgeInsets.all(8),
                    //       child: const Icon(
                    //         Icons.play_arrow,
                    //         color: Colors.white,
                    //         size: 30,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title with max 2 lines
            Text(
              movie.title ?? 'Unknown Title',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Rating row
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${movie.voteAverage?.toStringAsFixed(1) ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieImage(String posterPath) {
    if (kIsWeb) {
      return Image.network(
        "$imageUrl$posterPath",
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(color: Colors.grey[900]);
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        cacheWidth: 300,
        cacheHeight: 450,
      );
    }

    return CachedNetworkImage(
      imageUrl: "$imageUrl$posterPath",
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: Colors.grey[900]),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      fadeInDuration: const Duration(milliseconds: 200),
      memCacheWidth: 300,
      memCacheHeight: 450,
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.movie, color: Colors.white54, size: 40),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    if (movie.id == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(movieId: movie.id),
      ),
    );
  }
}

class _MovieLoadingCarousel extends StatelessWidget {
  const _MovieLoadingCarousel();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: 150,
          margin: const EdgeInsets.only(right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(height: 16, width: 100, color: Colors.grey[800]),
              const SizedBox(height: 4),
              Container(height: 12, width: 40, color: Colors.grey[800]),
            ],
          ),
        );
      },
    );
  }
}
