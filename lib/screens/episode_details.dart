import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/episode_details.dart';

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
  bool _isLoading = false;
  bool _showPlayer = false;
  String? _errorMessage;
  String _iframeViewType = '';

  @override
  void initState() {
    super.initState();
    _iframeViewType = 'video-player-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Constructs the streaming URL for vidsrc.xyz
  String _buildStreamingUrl() {
    final validSeasonNumber = widget.seasonNumber < 1 ? 1 : widget.seasonNumber;

    // First priority: Use passed IMDB ID
    if (widget.imdbId != null && widget.imdbId!.isNotEmpty) {
      final formattedImdbId =
          widget.imdbId!.startsWith('tt')
              ? widget.imdbId!
              : 'tt${widget.imdbId}';
      return 'https://vidsrc.xyz/embed/tv?imdb=$formattedImdbId&season=$validSeasonNumber&episode=${widget.episode.episodeNumber}&autoplay=1';
    }

    // Second priority: Use IMDB ID from seasonDetails
    if (widget.seasonDetails?.tmdbId?.imdbId != null &&
        widget.seasonDetails!.tmdbId!.imdbId.isNotEmpty) {
      final imdbIdFromDetails = widget.seasonDetails!.tmdbId!.imdbId;
      final formattedImdbId =
          imdbIdFromDetails.startsWith('tt')
              ? imdbIdFromDetails
              : 'tt$imdbIdFromDetails';
      return 'https://vidsrc.xyz/embed/tv?imdb=$formattedImdbId&season=$validSeasonNumber&episode=${widget.episode.episodeNumber}&autoplay=1';
    }

    // Third priority: Use TMDB ID from seasonDetails
    if (widget.seasonDetails?.tmdbId?.id != null &&
        widget.seasonDetails!.tmdbId!.id > 0) {
      return 'https://vidsrc.xyz/embed/tv?tmdb=${widget.seasonDetails!.tmdbId!.id}&season=$validSeasonNumber&episode=${widget.episode.episodeNumber}&autoplay=1';
    }

    // Final fallback: Use the original seriesId
    return 'https://vidsrc.xyz/embed/tv?tmdb=${widget.seriesId}&season=$validSeasonNumber&episode=${widget.episode.episodeNumber}&autoplay=1';
  }

  void _startPlaying() {
    if (kIsWeb) {
      try {
        final streamingUrl = _buildStreamingUrl();
        debugPrint('Loading streaming URL: $streamingUrl');

        // Register the iframe view factory for web
        ui.platformViewRegistry.registerViewFactory(
          _iframeViewType,
          (int viewId) =>
              html.IFrameElement()
                ..src = streamingUrl
                ..style.border = 'none'
                ..style.width = '100%'
                ..style.height = '100%'
                ..allow =
                    'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
                ..allowFullscreen = true,
        );

        setState(() {
          _showPlayer = true;
          _isLoading = false;
          _errorMessage = null;
        });
      } catch (e) {
        debugPrint('Error starting playback: $e');
        setState(() {
          _errorMessage = 'Error starting video: $e';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Video playback is only supported on web platform';
      });
    }
  }

  void _stopPlaying() {
    setState(() {
      _showPlayer = false;
      _isLoading = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showPlayer) {
      return _buildVideoPlayerScreen();
    }
    return _buildEpisodeDetailsScreen();
  }

  Widget _buildVideoPlayerScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.episode.name,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _stopPlaying,
            tooltip: 'Close Player',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _startPlaying,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (kIsWeb)
            HtmlElementView(viewType: _iframeViewType)
          else
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.web_asset_off, color: Colors.grey, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Video playback is only supported on web platform',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEpisodeDetailsScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Hero Section with Episode Still
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Episode Still Image
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

                  // Gradient Overlay
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

                  // Play Button Overlay
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
                  // Platform indicator
                  if (!kIsWeb)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Video playback is only available on web platform',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Breadcrumb Navigation
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

                  // Episode Metadata
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

          // Play Button Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: kIsWeb ? _startPlaying : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kIsWeb ? Colors.red : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    kIsWeb ? Icons.play_arrow : Icons.web_asset_off,
                    size: 24,
                  ),
                  label: Text(
                    kIsWeb ? 'Play Episode' : 'Web Only',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Overview Section
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

          // Debug Info Section
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
