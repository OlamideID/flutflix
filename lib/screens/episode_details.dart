import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:url_launcher/url_launcher.dart';

class EpisodeDetailsScreen extends ConsumerWidget {
  final Episode episode;
  final int seriesId;
  final int seasonNumber;
  final String seriesName;
  final String seasonName;
  final String? imdbId;
  final EpisodeDetails? seasonDetails; // Pass season details for URL building

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

  /// Constructs the streaming URL for vidsrc.xyz
  String _buildStreamingUrl() {
    final validSeasonNumber = seasonNumber < 1 ? 1 : seasonNumber;

    // First priority: Use passed IMDB ID
    if (imdbId != null && imdbId!.isNotEmpty) {
      final formattedImdbId = imdbId!.startsWith('tt') ? imdbId! : 'tt$imdbId';
      return 'https://vidsrc.xyz/embed/tv?imdb=$formattedImdbId&season=$validSeasonNumber&episode=${episode.episodeNumber}&autoplay=1';
    }

    // Second priority: Use IMDB ID from seasonDetails
    if (seasonDetails?.tmdbId?.imdbId != null &&
        seasonDetails!.tmdbId!.imdbId.isNotEmpty) {
      final imdbIdFromDetails = seasonDetails!.tmdbId!.imdbId;
      final formattedImdbId =
          imdbIdFromDetails.startsWith('tt')
              ? imdbIdFromDetails
              : 'tt$imdbIdFromDetails';
      return 'https://vidsrc.xyz/embed/tv?imdb=$formattedImdbId&season=$validSeasonNumber&episode=${episode.episodeNumber}&autoplay=1';
    }

    // Third priority: Use TMDB ID from seasonDetails
    if (seasonDetails?.tmdbId?.id != null && seasonDetails!.tmdbId!.id > 0) {
      return 'https://vidsrc.xyz/embed/tv?tmdb=${seasonDetails!.tmdbId!.id}&season=$validSeasonNumber&episode=${episode.episodeNumber}&autoplay=1';
    }

    // Final fallback: Use the original seriesId
    return 'https://vidsrc.xyz/embed/tv?tmdb=$seriesId&season=$validSeasonNumber&episode=${episode.episodeNumber}&autoplay=1';
  }

  Future<void> _launchPlayUrl(BuildContext context) async {
    final playUrl = _buildStreamingUrl();
    debugPrint('Launching URL: $playUrl');

    final uri = Uri.parse(playUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch video player for: $playUrl'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  if (episode.stillPath != null &&
                      episode.stillPath!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: "$imageUrl${episode.stillPath}",
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
                        onPressed: () => _launchPlayUrl(context),
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
                  // Breadcrumb Navigation
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$seriesName > $seasonName',
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
                          'E${episode.episodeNumber}',
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
                          episode.name,
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
                        '${episode.airDate.day}/${episode.airDate.month}/${episode.airDate.year}',
                      ),
                      if (episode.runtime > 0)
                        _buildMetadataItem(
                          Icons.access_time,
                          '${episode.runtime} min',
                        ),
                      if (episode.voteAverage > 0)
                        _buildMetadataItem(
                          Icons.star,
                          '${episode.voteAverage.toStringAsFixed(1)}/10',
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
                  onPressed: () => _launchPlayUrl(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: const Text(
                    'Play Episode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),

          // Overview Section
          if (episode.overview.isNotEmpty) ...[
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
                  episode.overview,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],

          // Guest Stars Section (if available in your Episode model)
          // if (episode.guestStars != null && episode.guestStars!.isNotEmpty) ...[
          //   const SliverToBoxAdapter(
          //     child: Padding(
          //       padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          //       child: Text(
          //         'Guest Stars',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 20,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ),
          //   SliverToBoxAdapter(
          //     child: SizedBox(
          //       height: 120,
          //       child: ListView.builder(
          //         scrollDirection: Axis.horizontal,
          //         padding: const EdgeInsets.symmetric(horizontal: 16),
          //         itemCount: episode.guestStars!.length,
          //         itemBuilder: (context, index) {
          //           final person = episode.guestStars![index];
          //           return _buildPersonCard(person);
          //         },
          //       ),
          //     ),
          //   ),
          // ],

          // Debug Information (remove in production)
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
                      'Series ID: $seriesId',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Season: $seasonNumber',
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                    Text(
                      'Episode: ${episode.episodeNumber}',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                    if (imdbId != null && imdbId!.isNotEmpty)
                      Text(
                        'IMDB ID: $imdbId',
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

          // Bottom Padding
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

  // Widget _buildPersonCard(Person person) {
  //   return Container(
  //     width: 80,
  //     margin: const EdgeInsets.only(right: 12),
  //     child: Column(
  //       children: [
  //         ClipRRect(
  //           borderRadius: BorderRadius.circular(40),
  //           child: CachedNetworkImage(
  //             imageUrl: "$imageUrl${person.profilePath}",
  //             width: 80,
  //             height: 80,
  //             fit: BoxFit.cover,
  //             placeholder: (context, url) => Container(
  //               color: Colors.grey[800],
  //               child: const Icon(Icons.person, color: Colors.grey),
  //             ),
  //             errorWidget: (context, url, error) => Container(
  //               color: Colors.grey[800],
  //               child: const Icon(Icons.person, color: Colors.grey),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           person.name,
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 12,
  //           ),
  //           textAlign: TextAlign.center,
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
