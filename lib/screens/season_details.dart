import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/components/series/season_cast.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:netflix/screens/episode_details.dart';
import 'package:netflix/services/api_service.dart';

final seasonDetailsProvider = FutureProvider.family<
  EpisodeDetails?,
  ({int seriesId, int seasonNumber})
>((ref, params) async {
  final api = ApiService();

  debugPrint(
    'Fetching episode details for series ${params.seriesId}, season ${params.seasonNumber}',
  );

  var result = await api.getEpisodeDetails(
    params.seriesId,
    params.seasonNumber,
  );

  // Only fall back to season 1 if the requested season doesn't exist AND it's not season 1
  if (result == null && params.seasonNumber != 1) {
    debugPrint(
      'Season ${params.seasonNumber} not found, trying season 1 as fallback',
    );
    result = await api.getEpisodeDetails(params.seriesId, 1);
  }

  if (result == null) {
    debugPrint('No episode details found for series ${params.seriesId}');
  } else {
    debugPrint(
      'Successfully loaded ${result.episodes.length} episodes for ${result.name}',
    );
  }

  return result;
});

final externalIdsProvider = FutureProvider.family<Map<String, dynamic>?, int>((
  ref,
  seriesId,
) async {
  final api = ApiService();
  return await api.getExternalIds(seriesId);
});

class SeasonDetailsScreen extends ConsumerStatefulWidget {
  final int seriesId;
  final int seasonNumber;
  final int? seasonId;
  final String seasonName;
  final String seriesName;
  final String? imdbId;

  const SeasonDetailsScreen({
    super.key,
    required this.seriesId,
    required this.seasonNumber,
    this.seasonId,
    required this.seasonName,
    required this.seriesName,
    this.imdbId,
  });

  @override
  ConsumerState<SeasonDetailsScreen> createState() =>
      _SeasonDetailsScreenState();
}

class _SeasonDetailsScreenState extends ConsumerState<SeasonDetailsScreen> {
  bool _isLoading = false;
  bool _showPlayer = false;
  String? _errorMessage;
  String _iframeViewType = '';
  int? _currentEpisodeNumber;
  EpisodeDetails? _currentSeasonDetails;

  @override
  void initState() {
    super.initState();
    _iframeViewType = 'video-player-${DateTime.now().millisecondsSinceEpoch}';
  }

  String _buildStreamingUrl(int episodeNumber, EpisodeDetails? seasonDetails) {
    final validSeasonNumber = widget.seasonNumber < 1 ? 1 : widget.seasonNumber;

    if (widget.imdbId != null && widget.imdbId!.isNotEmpty) {
      final formattedImdbId =
          widget.imdbId!.startsWith('tt')
              ? widget.imdbId!
              : 'tt${widget.imdbId}';
      return 'https://vidsrc.xyz/embed/tv?imdb=$formattedImdbId&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
    }

    if (seasonDetails?.tmdbId?.imdbId != null &&
        seasonDetails!.tmdbId!.imdbId.isNotEmpty) {
      final imdbIdFromDetails = seasonDetails.tmdbId!.imdbId;
      final formattedImdbId =
          imdbIdFromDetails.startsWith('tt')
              ? imdbIdFromDetails
              : 'tt$imdbIdFromDetails';
      return 'https://vidsrc.xyz/embed/tv?imdb=$formattedImdbId&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
    }

    if (seasonDetails?.tmdbId?.id != null && seasonDetails!.tmdbId!.id > 0) {
      return 'https://vidsrc.xyz/embed/tv?tmdb=${seasonDetails.tmdbId!.id}&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
    }

    return 'https://vidsrc.xyz/embed/tv?tmdb=${widget.seriesId}&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
  }

  void _startPlaying(int episodeNumber, EpisodeDetails seasonDetails) {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _showPlayer = true;
      _currentEpisodeNumber = episodeNumber;
      _currentSeasonDetails = seasonDetails;
      _errorMessage = null;
    });

    if (kIsWeb) {
      try {
        final streamingUrl = _buildStreamingUrl(episodeNumber, seasonDetails);
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
          _isLoading = false;
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
        _isLoading = false;
      });
    }
  }

  void _stopPlaying() {
    if (!mounted) return;
    setState(() {
      _showPlayer = false;
      _isLoading = false;
      _errorMessage = null;
      _currentEpisodeNumber = null;
      _currentSeasonDetails = null;
    });
  }

  Widget _buildVideoPlayerScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _currentEpisodeNumber != null && _currentSeasonDetails != null
              ? '${widget.seriesName} - S${widget.seasonNumber}E$_currentEpisodeNumber'
              : 'Video Player',
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
                    onPressed: () {
                      if (_currentEpisodeNumber != null &&
                          _currentSeasonDetails != null) {
                        _startPlaying(
                          _currentEpisodeNumber!,
                          _currentSeasonDetails!,
                        );
                      }
                    },
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

  @override
  Widget build(BuildContext context) {
    if (_showPlayer) {
      return _buildVideoPlayerScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.seriesName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              widget.seasonName,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final seasonAsync = ref.watch(
            seasonDetailsProvider((
              seriesId: widget.seriesId,
              seasonNumber: widget.seasonNumber,
            )),
          );

          return seasonAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading season: $error',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.seasonId != null) {
                            debugPrint(
                              'Retrying with season ID: ${widget.seasonId}',
                            );
                          }
                        },
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
            data: (seasonDetails) {
              if (seasonDetails == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tv_off, color: Colors.grey, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        widget.seasonNumber == 0
                            ? 'Season 0 (Specials) not available'
                            : 'Season ${widget.seasonNumber} not available',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This season might not exist for this series.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (widget.seasonNumber != 1) ...[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SeasonDetailsScreen(
                                      seriesId: widget.seriesId,
                                      seasonNumber: 1,
                                      seasonId: null,
                                      seasonName: 'Season 1',
                                      seriesName: widget.seriesName,
                                      imdbId: widget.imdbId,
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Go to Season 1'),
                        ),
                        const SizedBox(height: 8),
                      ],
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final availableImdbId =
                  seasonDetails.tmdbId?.imdbId ?? widget.imdbId;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: "$imageUrl${seasonDetails.posterPath}",
                              width: 120,
                              height: 180,
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
                                    child: const Icon(
                                      Icons.tv,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
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
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        seasonDetails.voteAverage
                                            .toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (availableImdbId != null &&
                                        availableImdbId.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'IMDB ID: $availableImdbId',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                    if (seasonDetails.tmdbId?.id != null &&
                                        seasonDetails.tmdbId!.id > 0) ...[
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
                                      'Series ID: ${widget.seriesId}',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SeasonCastSection(
                      seriesId: widget.seriesId,
                      seasonNumber: widget.seasonNumber,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'Episodes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final episode = seasonDetails.episodes[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EpisodeDetailsScreen(
                                      episode: episode,
                                      seriesId: widget.seriesId,
                                      seasonNumber: widget.seasonNumber,
                                      seriesName: widget.seriesName,
                                      seasonName: widget.seasonName,
                                      imdbId: availableImdbId,
                                      seasonDetails: seasonDetails,
                                    ),
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: "$imageUrl${episode.stillPath}",
                                  width: 160,
                                  height: 90,
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
                                        child: const Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.grey,
                                          size: 32,
                                        ),
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
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
                                          // Quick Play Button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.play_circle_fill,
                                              color: Colors.red,
                                              size: 28,
                                            ),
                                            onPressed: () {
                                              _startPlaying(
                                                episode.episodeNumber,
                                                seasonDetails,
                                              );
                                            },
                                            tooltip: 'Play episode',
                                          ),
                                          // Info Button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.info_outline,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => EpisodeDetailsScreen(
                                                        episode: episode,
                                                        seriesId:
                                                            widget.seriesId,
                                                        seasonNumber:
                                                            widget.seasonNumber,
                                                        seriesName:
                                                            widget.seriesName,
                                                        seasonName:
                                                            widget.seasonName,
                                                        imdbId: availableImdbId,
                                                        seasonDetails:
                                                            seasonDetails,
                                                      ),
                                                ),
                                              );
                                            },
                                            tooltip: 'Episode details',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${episode.runtime} min',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (episode.overview.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          episode.overview,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: seasonDetails.episodes.length),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
