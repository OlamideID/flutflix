import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/series_details.dart';

class SeasonCard extends StatelessWidget {
  final Season season;
  final SeriesDetails series;

  const SeasonCard({super.key, required this.season, required this.series});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: CachedNetworkImage(
              // Use season poster if available, otherwise use series poster
              // ignore: unnecessary_null_comparison
              imageUrl:
                      "$imageUrl${series.posterPath}",
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.tv, color: Colors.grey, size: 32),
                  ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    season.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${season.episodeCount} episodes • ${season.airDate.year}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (season.voteAverage > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          season.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                  if (season.overview.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      season.overview,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
