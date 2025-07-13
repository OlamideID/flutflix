import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:netflix/models/episode_details.dart';

class VideoPlayerController extends ChangeNotifier {
  bool _isLoading = false;
  bool _showPlayer = false;
  String? _errorMessage;
  String _iframeViewType = '';
  int? _currentEpisodeNumber;
  EpisodeDetails? _currentSeasonDetails;

  bool get isLoading => _isLoading;
  bool get showPlayer => _showPlayer;
  String? get errorMessage => _errorMessage;
  String get iframeViewType => _iframeViewType;
  int? get currentEpisodeNumber => _currentEpisodeNumber;
  EpisodeDetails? get currentSeasonDetails => _currentSeasonDetails;

  VideoPlayerController() {
    _iframeViewType = 'video-player-${DateTime.now().millisecondsSinceEpoch}';
  }

  String _buildStreamingUrl(
    int episodeNumber,
    EpisodeDetails? seasonDetails,
    int seriesId,
    int seasonNumber,
    String? imdbId,
  ) {
    final validSeasonNumber = seasonNumber < 1 ? 1 : seasonNumber;

    if (imdbId != null && imdbId.isNotEmpty) {
      final formattedImdbId = imdbId.startsWith('tt') ? imdbId : 'tt$imdbId';
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

    return 'https://vidsrc.xyz/embed/tv?tmdb=$seriesId&season=$validSeasonNumber&episode=$episodeNumber&autoplay=1';
  }

  void startPlaying(
    int episodeNumber,
    EpisodeDetails seasonDetails,
    int seriesId,
    int seasonNumber,
    String? imdbId,
  ) {
    _isLoading = true;
    _showPlayer = true;
    _currentEpisodeNumber = episodeNumber;
    _currentSeasonDetails = seasonDetails;
    _errorMessage = null;
    notifyListeners();

    if (kIsWeb) {
      try {
        final streamingUrl = _buildStreamingUrl(
          episodeNumber,
          seasonDetails,
          seriesId,
          seasonNumber,
          imdbId,
        );
        debugPrint('Loading streaming URL: $streamingUrl');

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

        _isLoading = false;
        notifyListeners();
      } catch (e) {
        debugPrint('Error starting playback: $e');
        _errorMessage = 'Error starting video: $e';
        _isLoading = false;
        notifyListeners();
      }
    } else {
      _errorMessage = 'Video playback is only supported on web platform';
      _isLoading = false;
      notifyListeners();
    }
  }

  void stopPlaying() {
    _showPlayer = false;
    _isLoading = false;
    _errorMessage = null;
    _currentEpisodeNumber = null;
    _currentSeasonDetails = null;
    notifyListeners();
  }

  void retry() {
    if (_currentEpisodeNumber != null && _currentSeasonDetails != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final VideoPlayerController controller;
  final String seriesName;
  final int seasonNumber;

  const VideoPlayerScreen({
    super.key,
    required this.controller,
    required this.seriesName,
    required this.seasonNumber,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildAppBar(context),
          body: _buildBody(context),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        controller.currentEpisodeNumber != null
            ? '$seriesName - S${seasonNumber}E${controller.currentEpisodeNumber}'
            : 'Video Player',
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: controller.stopPlaying,
          tooltip: 'Close Player',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        if (controller.errorMessage != null)
          _buildErrorWidget()
        else if (kIsWeb)
          HtmlElementView(viewType: controller.iframeViewType)
        else
          _buildWebOnlyMessage(),
        if (controller.isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              controller.errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.retry,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildWebOnlyMessage() {
    return const Center(
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
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(child: CircularProgressIndicator(color: Colors.red)),
    );
  }
}
