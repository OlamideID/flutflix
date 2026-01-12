// movie_details_widgets.dart
import 'package:flutter/material.dart';
import 'package:netflix/features/movie_details/model/movie_details_model.dart';

class MovieDetailsHeader extends StatelessWidget {
  final Moviedetail movie;

  const MovieDetailsHeader({super.key, required this.movie});

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
              '${movie.releaseDate?.year ?? 'Unknown'}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${movie.runtime ?? 'N/A'} min',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${movie.voteAverage}/10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class MovieDetailsContent extends StatelessWidget {
  final Moviedetail movie;

  const MovieDetailsContent({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((movie.tagline?.isNotEmpty ?? false)) ...[
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
            children: movie.genres.map((genre) {
              return Container(
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
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        MovieStatsSection(movie: movie),
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
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
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
            children: movie.spokenLanguages
                .map(
                  (language) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[600]!,
                      ),
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
      ],
    );
  }
}

class MovieStatsSection extends StatelessWidget {
  final Moviedetail movie;

  const MovieStatsSection({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        _buildStatRow(
          'Vote Count',
          '${_formatNumber(movie.voteCount)} votes',
        ),
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
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    }
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}