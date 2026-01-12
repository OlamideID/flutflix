// season_header_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/episode_details.dart';

class SeasonHeaderWidget extends StatelessWidget {
  final EpisodeDetails seasonDetails;
  final int seriesId;
  final String? availableImdbId;

  const SeasonHeaderWidget({
    super.key,
    required this.seasonDetails,
    required this.seriesId,
    this.availableImdbId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPosterImage(),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSeasonInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: "$imageUrl${seasonDetails.posterPath}",
        width: 120,
        height: 180,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.red,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[800],
          child: const Icon(
            Icons.tv,
            color: Colors.grey,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          seasonDetails.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${seasonDetails.episodes.length} episodes • ${seasonDetails.airDate.year}',
          style: const TextStyle(color: Colors.grey),
        ),
        if (seasonDetails.voteAverage > 0) ...[
          const SizedBox(height: 4),
          _buildRatingRow(),
        ],
        if (seasonDetails.overview.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            seasonDetails.overview,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
        _buildIdSection(),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        const Icon(
          Icons.star,
          color: Colors.amber,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          seasonDetails.voteAverage.toStringAsFixed(1),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildIdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (availableImdbId != null && availableImdbId!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'IMDB ID: $availableImdbId',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
            ),
          ),
        ],
        if (seasonDetails.tmdbId?.id != null && seasonDetails.tmdbId!.id > 0) ...[
          const SizedBox(height: 4),
          Text(
            'TMDB ID: ${seasonDetails.tmdbId!.id}',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          'Series ID: $seriesId',
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}