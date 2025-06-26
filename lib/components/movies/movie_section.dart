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
              error: (e, _) {
                if (kDebugMode) {
                  print('MovieSection - Error loading movies: $e');
                }
                return ErrorDisplay(error: e.toString());
              },
              data: (data) {
                if (kDebugMode) {
                  print(
                    'MovieSection - Data received: ${data?.results?.length ?? 0} movies',
                  );
                  if (data?.results?.isNotEmpty == true) {
                    print(
                      'MovieSection - First movie poster: ${data!.results![0].posterPath}',
                    );
                  }
                }

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
    // Debug logging
    if (kDebugMode) {
      print('_MovieCarouselCard - Movie: ${movie.title}');
      print('_MovieCarouselCard - PosterPath: ${movie.posterPath}');
    }

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
                          movie.posterPath != null &&
                                  movie.posterPath!.isNotEmpty
                              ? _buildMovieImage(movie.posterPath!)
                              : _buildErrorPlaceholder(),
                    ),

                    // Gradient Overlay - only show if image loads successfully
                    if (movie.posterPath != null &&
                        movie.posterPath!.isNotEmpty)
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
    final fullImageUrl = "$imageUrl$posterPath";

    if (kDebugMode) {
      print('_MovieCarouselCard - Full image URL: $fullImageUrl');
    }

    if (kIsWeb) {
      return Image.network(
        fullImageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            if (kDebugMode) {
              print('_MovieCarouselCard - Image loaded: $fullImageUrl');
            }
            return child;
          }
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('_MovieCarouselCard - Image error: $error');
            print('_MovieCarouselCard - Failed URL: $fullImageUrl');
          }
          return _buildErrorPlaceholder();
        },
        cacheWidth: 300,
        cacheHeight: 450,
      );
    }

    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget: (context, url, error) {
        if (kDebugMode) {
          print('CachedNetworkImage - Error: $error, URL: $url');
        }
        return _buildErrorPlaceholder();
      },
      fadeInDuration: const Duration(milliseconds: 200),
      memCacheWidth: 300,
      memCacheHeight: 450,
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, color: Colors.white54, size: 40),
            SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
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
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
