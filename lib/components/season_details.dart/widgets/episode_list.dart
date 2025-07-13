// episode_list_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/episode_details.dart';

class EpisodeListWidget extends StatelessWidget {
  final List<Episode> episodes;
  final Function(Episode) onEpisodeTap;
  final Function(Episode) onPlayTap;

  const EpisodeListWidget({
    super.key,
    required this.episodes,
    required this.onEpisodeTap,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final episode = episodes[index];
          return EpisodeCard(
            episode: episode,
            onTap: () => onEpisodeTap(episode),
            onPlayTap: () => onPlayTap(episode),
          );
        },
        childCount: episodes.length,
      ),
    );
  }
}

class EpisodeCard extends StatelessWidget {
  final Episode episode;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;

  const EpisodeCard({
    super.key,
    required this.episode,
    required this.onTap,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEpisodeImage(),
            Expanded(
              child: _buildEpisodeInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
      child: CachedNetworkImage(
        imageUrl: "$imageUrl${episode.stillPath}",
        width: 160,
        height: 90,
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
            Icons.play_circle_outline,
            color: Colors.grey,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEpisodeHeader(),
          const SizedBox(height: 4),
          Text(
            '${episode.runtime} min',
            style: const TextStyle(color: Colors.grey),
          ),
          if (episode.overview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              episode.overview,
              style: const TextStyle(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Tap for details',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeHeader() {
    return Row(
      children: [
        Text(
          '${episode.episodeNumber}.',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            episode.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.play_circle_fill,
            color: Colors.red,
            size: 28,
          ),
          onPressed: onPlayTap,
          tooltip: 'Play episode',
        ),
        IconButton(
          icon: const Icon(
            Icons.info_outline,
            color: Colors.white,
            size: 24,
          ),
          onPressed: onTap,
          tooltip: 'Episode details',
        ),
      ],
    );
  }
}