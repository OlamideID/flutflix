import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/components/season_details.dart/utils.dart';
import 'package:netflix/components/season_details.dart/widgets/episode_list.dart';
import 'package:netflix/components/season_details.dart/widgets/season_cast.dart';
import 'package:netflix/components/season_details.dart/widgets/season_header.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:netflix/screens/episode_details.dart';
import 'package:url_launcher/url_launcher.dart';

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
  @override
  Widget build(BuildContext context) {
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
              setState(() {});
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tv_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Season ${widget.seasonNumber} not available',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
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

  Future<void> _startPlaying(
    Episode episode,
    EpisodeDetails seasonDetails,
  ) async {
    final int seasonNumber = widget.seasonNumber < 1 ? 1 : widget.seasonNumber;
    final String? imdbId = widget.imdbId ?? seasonDetails.tmdbId?.imdbId;
    final int? tmdbId = seasonDetails.tmdbId?.id;

    String url;

    if (imdbId != null && imdbId.isNotEmpty) {
      final formattedImdbId = imdbId.startsWith('tt') ? imdbId : 'tt$imdbId';
      url =
          'https://vidsrc.xyz/embed/tv?imdb=$formattedImdbId&season=$seasonNumber&episode=${episode.episodeNumber}&autoplay=1';
    } else if (tmdbId != null && tmdbId > 0) {
      url =
          'https://vidsrc.xyz/embed/tv?tmdb=$tmdbId&season=$seasonNumber&episode=${episode.episodeNumber}&autoplay=1';
    } else {
      url =
          'https://vidsrc.xyz/embed/tv?tmdb=${widget.seriesId}&season=$seasonNumber&episode=${episode.episodeNumber}&autoplay=1';
    }

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open video link')),
      );
    }
  }
}
