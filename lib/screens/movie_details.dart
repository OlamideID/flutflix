import 'dart:js' as js; // Only works on web

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/movie_details_model.dart';
import 'package:netflix/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

final movieDetailsProvider = FutureProvider.family<Moviedetail?, int>((
  ref,
  movieId,
) async {
  final api = ApiService();
  return await api.movieDetails(movieId);
});

class MovieDetailsScreen extends ConsumerWidget {
  const MovieDetailsScreen({super.key, required this.movieId});
  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final movieAsync = ref.watch(movieDetailsProvider(movieId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: movieAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        data: (movie) {
          if (movie == null) {
            return const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: size.height * 0.5,
                pinned: true,
                backgroundColor: Colors.black,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            "$imageUrl${movie.backdropPath.isNotEmpty ? movie.backdropPath : movie.posterPath}",
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.error,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                              Colors.black,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _MovieDetailsBody(movie: movie),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MovieDetailsBody extends StatelessWidget {
  const _MovieDetailsBody({required this.movie});
  final Moviedetail movie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${movie.releaseDate.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(width: 16),
            Text(
              '${movie.runtime} min',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${movie.voteAverage}/10',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = getVideoUrl(movie.id.toString());
                  await openUrl(url);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.play_arrow, size: 24),
                label: const Text(
                  'Play',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
                  'My List',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (movie.tagline.isNotEmpty) ...[
          Text(
            '"${movie.tagline}"',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Text(
          'Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.overview,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        if (movie.genres.isNotEmpty) ...[
          const Text(
            'Genres',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                movie.genres
                    .map(
                      (genre) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          genre.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
        ],
        _buildStatRow('Status', movie.status),
        _buildStatRow(
          'Original Language',
          movie.originalLanguage.toUpperCase(),
        ),
        _buildStatRow(
          'Budget',
          movie.budget > 0 ? '\$${_formatNumber(movie.budget)}' : 'Unknown',
        ),
        _buildStatRow(
          'Revenue',
          movie.revenue > 0 ? '\$${_formatNumber(movie.revenue)}' : 'Unknown',
        ),
        _buildStatRow('Vote Count', '${_formatNumber(movie.voteCount)} votes'),
        const SizedBox(height: 24),
        if (movie.productionCompanies.isNotEmpty) ...[
          const Text(
            'Production Companies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...movie.productionCompanies.map(
            (company) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• ${company.name}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (movie.spokenLanguages.isNotEmpty) ...[
          const Text(
            'Languages',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                movie.spokenLanguages
                    .map(
                      (language) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[600]!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          language.englishName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000000)
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}

String getVideoUrl(String movieId) => 'https://vidsrc.icu/embed/movie/$movieId';

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
