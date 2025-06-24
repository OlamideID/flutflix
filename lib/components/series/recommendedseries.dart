import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/providers/providers.dart';
import 'package:netflix/screens/series_detailscreen.dart';

import '../../models/recommended_series.dart';

class RecommendedSeriesSection extends ConsumerWidget {
  const RecommendedSeriesSection({super.key, required this.seriesId});
  final int seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedSeriesAsync = ref.watch(
      recommendedSeriesProvider(seriesId),
    );

    return recommendedSeriesAsync.when(
      loading:
          () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      error: (error, _) => const SizedBox.shrink(),
      data: (recommended) {
        if (recommended == null || recommended.results.isEmpty) {
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
                  itemCount: recommended.results.length,
                  itemBuilder: (context, index) {
                    final series = recommended.results[index];
                    return RecommendedSeriesCard(series: series);
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

class RecommendedSeriesCard extends StatelessWidget {
  const RecommendedSeriesCard({super.key, required this.series});
  final Result series;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          print(series.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeriesDetailsScreen(id: series.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildPosterImage(),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              series.name, // Using name instead of title for TV series
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
    if (series.posterPath.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: "$imageUrl${series.posterPath}",
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
      child: const Center(child: Icon(Icons.tv, color: Colors.white, size: 30)),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 12),
        const SizedBox(width: 2),
        Text(
          series.voteAverage > 0
              ? series.voteAverage.toStringAsFixed(1)
              : 'N/A',
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }
}
