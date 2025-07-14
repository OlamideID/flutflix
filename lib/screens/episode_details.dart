import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:url_launcher/url_launcher.dart';

class EpisodeDetailsScreen extends ConsumerStatefulWidget {
  final Episode episode;
  final int seriesId;
  final int seasonNumber;
  final String seriesName;
  final String seasonName;
  final String? imdbId;
  final EpisodeDetails? seasonDetails;

  const EpisodeDetailsScreen({
    super.key,
    required this.episode,
    required this.seriesId,
    required this.seasonNumber,
    required this.seriesName,
    required this.seasonName,
    this.imdbId,
    this.seasonDetails,
  });

  @override
  ConsumerState<EpisodeDetailsScreen> createState() =>
      _EpisodeDetailsScreenState();
}

class _EpisodeDetailsScreenState extends ConsumerState<EpisodeDetailsScreen> {
  Future<void> _startPlaying() async {
    final url = _buildStreamingUrl();
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open streaming link')),
      );
    }
  }

  String _buildStreamingUrl() {
    final validSeasonNumber = widget.seasonNumber < 1 ? 1 : widget.seasonNumber;
    final episodeNumber = widget.episode.episodeNumber;

    if (widget.imdbId != null && widget.imdbId!.isNotEmpty) {
      final formatted =
          widget.imdbId!.startsWith('tt')
              ? widget.imdbId!
              : 'tt${widget.imdbId}';
      return 'https://vidsrc.xyz/embed/tv?imdb=$formatted&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
    }

    if (widget.seasonDetails?.tmdbId?.imdbId != null &&
        widget.seasonDetails!.tmdbId!.imdbId.isNotEmpty) {
      final imdb = widget.seasonDetails!.tmdbId!.imdbId;
      final formatted = imdb.startsWith('tt') ? imdb : 'tt$imdb';
      return 'https://vidsrc.xyz/embed/tv?imdb=$formatted&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
    }

    if (widget.seasonDetails?.tmdbId?.id != null &&
        widget.seasonDetails!.tmdbId!.id > 0) {
      return 'https://vidsrc.xyz/embed/tv?tmdb=${widget.seasonDetails!.tmdbId!.id}&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
    }

    return 'https://vidsrc.xyz/embed/tv?tmdb=${widget.seriesId}&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.episode.stillPath != null &&
                      widget.episode.stillPath!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: "$imageUrl${widget.episode.stillPath}",
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: Colors.grey,
                              size: 64,
                            ),
                          ),
                    )
                  else
                    Container(
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.grey,
                        size: 64,
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
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: _startPlaying,
                        tooltip: 'Play Episode',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Episode Info Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.seriesName} > ${widget.seasonName}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'E${widget.episode.episodeNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.episode.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildMetadataItem(
                        Icons.calendar_today,
                        '${widget.episode.airDate.day}/${widget.episode.airDate.month}/${widget.episode.airDate.year}',
                      ),
                      if (widget.episode.runtime > 0)
                        _buildMetadataItem(
                          Icons.access_time,
                          '${widget.episode.runtime} min',
                        ),
                      if (widget.episode.voteAverage > 0)
                        _buildMetadataItem(
                          Icons.star,
                          '${widget.episode.voteAverage.toStringAsFixed(1)}/10',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _startPlaying,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Play Episode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),

          // Overview
          if (widget.episode.overview.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.episode.overview,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],

          // Debug Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Platform: ${kIsWeb ? 'Web' : 'Mobile/Desktop'}',
                      style: const TextStyle(color: Colors.cyan, fontSize: 12),
                    ),
                    Text(
                      'Series ID: ${widget.seriesId}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Season: ${widget.seasonNumber}',
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                    Text(
                      'Episode: ${widget.episode.episodeNumber}',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                    if (widget.imdbId != null && widget.imdbId!.isNotEmpty)
                      Text(
                        'IMDB ID: ${widget.imdbId}',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Streaming URL: ${_buildStreamingUrl()}',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}
