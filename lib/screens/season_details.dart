// season_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/components/season_details.dart/utils.dart';
import 'package:netflix/components/season_details.dart/video_player.dart';
import 'package:netflix/components/season_details.dart/widgets/episode_list.dart';
import 'package:netflix/components/season_details.dart/widgets/season_cast.dart';
import 'package:netflix/components/season_details.dart/widgets/season_header.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:netflix/screens/episode_details.dart';

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
  late final VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoPlayerController.showPlayer) {
      return VideoPlayerScreen(
        controller: _videoPlayerController,
        seriesName: widget.seriesName,
        seasonNumber: widget.seasonNumber,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (context, ref, child) {
        final seasonAsync = ref.watch(
          seasonDetailsProvider((
            seriesId: widget.seriesId,
            seasonNumber: widget.seasonNumber,
          )),
        );

        return seasonAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorWidget(error),
          data: (seasonDetails) => _buildSeasonContent(seasonDetails),
        );
      },
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
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
                debugPrint('Retrying with season ID: ${widget.seasonId}');
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
    );
  }

  Widget _buildSeasonContent(EpisodeDetails? seasonDetails) {
    if (seasonDetails == null) {
      return SeasonNotAvailableWidget(
        seasonNumber: widget.seasonNumber,
        seriesId: widget.seriesId,
        seriesName: widget.seriesName,
        imdbId: widget.imdbId,
      );
    }

    final availableImdbId = seasonDetails.tmdbId?.imdbId ?? widget.imdbId;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SeasonHeaderWidget(
            seasonDetails: seasonDetails,
            seriesId: widget.seriesId,
            availableImdbId: availableImdbId,
          ),
        ),
        SliverToBoxAdapter(
          child: SeasonCastWidget(
            seriesId: widget.seriesId,
            seasonNumber: widget.seasonNumber,
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Episodes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        EpisodeListWidget(
          episodes: seasonDetails.episodes,
          onEpisodeTap:
              (episode) => _navigateToEpisodeDetails(
                episode,
                availableImdbId,
                seasonDetails,
              ),
          onPlayTap: (episode) => _startPlaying(episode, seasonDetails),
        ),
      ],
    );
  }

  void _navigateToEpisodeDetails(
    Episode episode,
    String? availableImdbId,
    EpisodeDetails seasonDetails,
  ) {
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
  }

  void _startPlaying(Episode episode, EpisodeDetails seasonDetails) {
    _videoPlayerController.startPlaying(
      episode.episodeNumber,
      seasonDetails,
      widget.seriesId,
      widget.seasonNumber,
      widget.imdbId,
    );
  }
}

class SeasonNotAvailableWidget extends StatelessWidget {
  final int seasonNumber;
  final int seriesId;
  final String seriesName;
  final String? imdbId;

  const SeasonNotAvailableWidget({
    super.key,
    required this.seasonNumber,
    required this.seriesId,
    required this.seriesName,
    this.imdbId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tv_off, color: Colors.grey, size: 64),
          const SizedBox(height: 16),
          Text(
            seasonNumber == 0
                ? 'Season 0 (Specials) not available'
                : 'Season $seasonNumber not available',
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
          if (seasonNumber != 1) ...[
            ElevatedButton(
              onPressed: () => _navigateToSeason1(context),
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
            child: const Text('Go Back', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToSeason1(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => SeasonDetailsScreen(
              seriesId: seriesId,
              seasonNumber: 1,
              seasonId: null,
              seasonName: 'Season 1',
              seriesName: seriesName,
              imdbId: imdbId,
            ),
      ),
    );
  }
}
