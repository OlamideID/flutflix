// movie_trailer_player.dart
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieTrailerPlayer {
  final VoidCallback onTrailerStarted;
  final VoidCallback onTrailerStopped;
  final ValueChanged<bool> onLoadingChanged;
  final ValueChanged<String?> onErrorChanged;

  String _trailerIframeViewType = '';

  MovieTrailerPlayer({
    required this.onTrailerStarted,
    required this.onTrailerStopped,
    required this.onLoadingChanged,
    required this.onErrorChanged,
  }) {
    _trailerIframeViewType = 'trailer-player-${DateTime.now().millisecondsSinceEpoch}';
  }

  String _buildTrailerUrl(String youtubeKey) {
    return 'https://www.youtube.com/embed/$youtubeKey?autoplay=1&rel=0&showinfo=0&controls=1';
  }

  void playTrailer(BuildContext context, String youtubeKey) {
    if (kIsWeb) {
      try {
        onLoadingChanged(true);

        final trailerUrl = _buildTrailerUrl(youtubeKey);
        debugPrint('Loading trailer URL: $trailerUrl');

        ui.platformViewRegistry.registerViewFactory(
          _trailerIframeViewType,
          (int viewId) => html.IFrameElement()
            ..src = trailerUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
            ..allowFullscreen = true,
        );

        onTrailerStarted();
        onLoadingChanged(false);
        onErrorChanged(null);
      } catch (e) {
        debugPrint('Error starting trailer: $e');
        onErrorChanged('Error starting trailer: $e');
        onLoadingChanged(false);
      }
    } else {
      _showTrailerDialog(context, youtubeKey);
    }
  }

  void _showTrailerDialog(BuildContext context, String youtubeKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Watch Trailer',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Would you like to watch this trailer on YouTube?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final url = 'https://www.youtube.com/watch?v=$youtubeKey';
              _openUrl(url);
            },
            child: const Text(
              'Open YouTube',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    )) {
      throw 'Could not launch $url';
    }
  }

  Widget buildTrailerPlayer(String? errorMessage, bool isLoading) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Trailer', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onTrailerStopped,
            tooltip: 'Close Trailer',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onTrailerStopped,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            )
          else if (kIsWeb)
            HtmlElementView(viewType: _trailerIframeViewType)
          else
            const Center(
              child: Text(
                'Trailer playback is only supported on web platform',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.red)),
        ],
      ),
    );
  }
}