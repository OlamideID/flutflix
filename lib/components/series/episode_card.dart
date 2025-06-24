import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netflix/models/series_details.dart';

class EpisodeCard extends StatelessWidget {
  final LastEpisodeToAir episode;

  const EpisodeCard({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            episode.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Season ${episode.seasonNumber} • Episode ${episode.episodeNumber} • ${DateFormat.yMMMMd().format(episode.airDate)}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (episode.overview.isNotEmpty)
            Text(
              episode.overview,
              style: const TextStyle(color: Colors.white70),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              if (episode.runtime > 0)
                Text(
                  '${episode.runtime} min',
                  style: const TextStyle(color: Colors.grey),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${episode.voteAverage} (${episode.voteCount})',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}