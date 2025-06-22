import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:netflix/screens/episode_details.dart';
import 'package:netflix/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Only try fallback if the original season number was greater than 1
  // and we got null result (which could mean the season doesn't exist)
  if (result == null && params.seasonNumber > 1) {
    debugPrint(
      'Season ${params.seasonNumber} not found, trying season 1 as fallback',
    );
    result = await api.getEpisodeDetails(
      params.seriesId,
      1, // Always fallback to season 1, not seasonNumber - 1
    );
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

// Optional: Provider to get external IDs (including IMDB ID)
final externalIdsProvider = FutureProvider.family<Map<String, dynamic>?, int>((
  ref,
  seriesId,
) async {
  final api = ApiService();
  return await api.getExternalIds(seriesId);
});

class SeasonDetailsScreen extends ConsumerWidget {
  final int seriesId;
  final int seasonNumber;
  final int? seasonId;
  final String seasonName;
  final String seriesName;
  final String? imdbId; // Add IMDB ID parameter

  const SeasonDetailsScreen({
    super.key,
    required this.seriesId,
    required this.seasonNumber,
    this.seasonId,
    required this.seasonName,
    required this.seriesName,
    this.imdbId, // Optional IMDB ID
  });

  /// Constructs the streaming URL for vidsrc.xyz
  /// Prefers IMDB ID if available, falls back to TMDB ID from seasonDetails
  /// Uses query parameters for better reliability
  String _buildStreamingUrl(int episodeNumber, EpisodeDetails? seasonDetails) {
    // Ensure season number is at least 1 (never 0)
    final validSeasonNumber = seasonNumber < 1 ? 1 : seasonNumber;

    // First priority: Use passed IMDB ID
    if (imdbId != null && imdbId!.isNotEmpty) {
      final formattedImdbId = imdbId!.startsWith('tt') ? imdbId! : 'tt$imdbId';
      return 'https://vidsrc.xyz/embed/tv?imdb=$formattedImdbId&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
    }

    // Second priority: Use IMDB ID from seasonDetails.tmdbId
    if (seasonDetails?.tmdbId?.imdbId != null &&
        seasonDetails!.tmdbId!.imdbId.isNotEmpty) {
      final imdbIdFromDetails = seasonDetails.tmdbId!.imdbId;
      final formattedImdbId =
          imdbIdFromDetails.startsWith('tt')
              ? imdbIdFromDetails
              : 'tt$imdbIdFromDetails';
      return 'https://vidsrc.xyz/embed/tv?imdb=$formattedImdbId&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
    }

    // Third priority: Use TMDB ID from seasonDetails.tmdbId.id
    if (seasonDetails?.tmdbId?.id != null && seasonDetails!.tmdbId!.id > 0) {
      return 'https://vidsrc.xyz/embed/tv?tmdb=${seasonDetails.tmdbId!.id}&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
    }

    // Final fallback: Use the original seriesId (which should be TMDB ID)
    return 'https://vidsrc.xyz/embed/tv?tmdb=$seriesId&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonAsync = ref.watch(
      seasonDetailsProvider((seriesId: seriesId, seasonNumber: seasonNumber)),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              seriesName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              seasonName,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: seasonAsync.when(
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
                      if (seasonId != null) {
                        debugPrint('Retrying with season ID: $seasonId');
                        // Could retry logic here
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
            return const Center(
              child: Text(
                'No season data available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Extract IMDB ID from season details if available
          final availableImdbId = seasonDetails.tmdbId?.imdbId ?? imdbId;

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
                                    seasonDetails.voteAverage.toStringAsFixed(
                                      1,
                                    ),
                                    style: const TextStyle(color: Colors.grey),
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
                            // Debug info (remove in production)
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
                                  'Series ID: $seriesId',
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
                        // Navigate to Episode Details Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EpisodeDetailsScreen(
                                  episode: episode,
                                  seriesId: seriesId,
                                  seasonNumber: seasonNumber,
                                  seriesName: seriesName,
                                  seasonName: seasonName,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        onPressed: () async {
                                          // Direct play functionality
                                          final playUrl = _buildStreamingUrl(
                                            episode.episodeNumber,
                                            seasonDetails,
                                          );

                                          debugPrint('Launching URL: $playUrl');

                                          final uri = Uri.parse(playUrl);
                                          try {
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(
                                                uri,
                                                mode:
                                                    LaunchMode
                                                        .externalApplication,
                                              );
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Could not launch video player for: $playUrl',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            debugPrint(
                                              'Error launching URL: $e',
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Error launching video: $e',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
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
                                          // Navigate to Episode Details Screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      EpisodeDetailsScreen(
                                                        episode: episode,
                                                        seriesId: seriesId,
                                                        seasonNumber:
                                                            seasonNumber,
                                                        seriesName: seriesName,
                                                        seasonName: seasonName,
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
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (episode.overview.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      episode.overview,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      maxLines: 2, // Reduced to show less text
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  // Optional: Add a "Tap for more details" hint
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
      ),
    );
  }
}
