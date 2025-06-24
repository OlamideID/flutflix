import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/providers/providers.dart';
import 'package:netflix/screens/movie_details.dart';

import '../../models/recommend_movies.dart';

class RecommendedMoviesSection extends ConsumerWidget {
  const RecommendedMoviesSection({super.key, required this.movieId});
  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedMoviesAsync = ref.watch(
      recommendedMoviesProvider(movieId),
    );

    return recommendedMoviesAsync.when(
      loading:
          () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      error: (error, _) => const SizedBox.shrink(),
      data: (recommendedMovies) {
        if (recommendedMovies == null || recommendedMovies.results.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommended For You',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedMovies.results.length,
                  itemBuilder: (context, index) {
                    final movie = recommendedMovies.results[index];
                    return RecommendedMovieCard(movie: movie);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RecommendedMovieCard extends StatelessWidget {
  const RecommendedMovieCard({super.key, required this.movie});
  final Result movie;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          print(movie.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(movieId: movie.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildPosterImage(),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Rating
            _buildRatingRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterImage() {
    if (movie.posterPath.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: "$imageUrl${movie.posterPath}",
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.movie, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 12),
        const SizedBox(width: 2),
        Text(
          movie.voteAverage > 0 ? movie.voteAverage.toStringAsFixed(1) : 'N/A',
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }
}
