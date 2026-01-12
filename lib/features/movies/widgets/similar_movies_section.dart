import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/features/movies/models/similarmovies.dart';
import 'package:netflix/providers/providers.dart';
import 'package:netflix/screens/movie_details.dart';

class SimilarMoviesSection extends ConsumerWidget {
  const SimilarMoviesSection({super.key, required this.movieId});
  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarMoviesAsync = ref.watch(similarMoviesProvider(movieId));

    return similarMoviesAsync.when(
      loading:
          () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      error: (error, _) => const SizedBox.shrink(),
      data: (similarMovies) {
        if (similarMovies == null || similarMovies.results.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'More Like This',
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
                  itemCount: similarMovies.results.length,
                  itemBuilder: (context, index) {
                    final movie = similarMovies.results[index];
                    return SimilarMovieCard(movie: movie);
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

class SimilarMovieCard extends StatelessWidget {
  const SimilarMovieCard({super.key, required this.movie});
  final Result movie;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
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
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    movie.posterPath.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: "$imageUrl${movie.posterPath}",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                        )
                        : Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.movie,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title.isNotEmpty ? movie.title : 'Unknown Title',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 2),
                Text(
                  movie.voteAverage > 0
                      ? movie.voteAverage.toStringAsFixed(1)
                      : 'N/A',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
