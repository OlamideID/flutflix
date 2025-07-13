// movie_trailer_section.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/models/movie_trailer.dart';

class MovieTrailerSection extends StatelessWidget {
  final AsyncValue<MovieTrailer?> trailerAsync;
  final ValueChanged<String> onTrailerTap;

  const MovieTrailerSection({
    super.key,
    required this.trailerAsync,
    required this.onTrailerTap,
  });

  @override
  Widget build(BuildContext context) {
    return trailerAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
      data: (trailerData) {
        if (trailerData == null) {
          return const SizedBox.shrink();
        }
        return _buildTrailerSection(trailerData);
      },
    );
  }

  Widget _buildTrailerSection(MovieTrailer trailerData) {
    final youtubeTrailers = trailerData.results
        .where(
          (video) =>
              video.site.toLowerCase() == 'youtube' &&
              video.type.toLowerCase() == 'trailer',
        )
        .toList();

    if (youtubeTrailers.isEmpty) return const SizedBox.shrink();

    youtubeTrailers.sort((a, b) {
      if (a.official && !b.official) return -1;
      if (!a.official && b.official) return 1;
      return b.publishedAt.compareTo(a.publishedAt);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trailers',
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
            itemCount: youtubeTrailers.length,
            itemBuilder: (context, index) {
              final trailer = youtubeTrailers[index];
              return TrailerCard(
                trailer: trailer,
                onTap: () => onTrailerTap(trailer.key),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class TrailerCard extends StatelessWidget {
  final dynamic trailer; // Use your trailer model type
  final VoidCallback onTap;

  const TrailerCard({
    super.key,
    required this.trailer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = 'https://img.youtube.com/vi/${trailer.key}/hqdefault.jpg';

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[900],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: thumbnailUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.video_library,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black54,
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    if (trailer.official)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'OFFICIAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trailer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(trailer.publishedAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}