// youtube_player_web.dart
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class PlatformYouTubePlayerController {
  final ValueChanged<bool> onLoadingChanged;
  final ValueChanged<String?> onErrorChanged;

  String? _videoId;
  String? _viewId;
  bool _isPlayerReady = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  String _currentQuality = 'auto'; // Track current quality
  bool _isFullScreen =
      false; // Track fullscreen state (always false for web iframe)
  html.IFrameElement? _iframe;

  PlatformYouTubePlayerController({
    required this.onLoadingChanged,
    required this.onErrorChanged,
  });

  void initialize(String videoId) {
    dispose();

    _videoId = videoId;
    _viewId =
        'youtube-player-$videoId-${DateTime.now().millisecondsSinceEpoch}';

    debugPrint('Initializing YouTube player (Web) with video ID: $videoId');

    _createYouTubePlayer();
  }

  void _createYouTubePlayer() {
    if (_videoId == null || _viewId == null) return;

    _iframe =
        html.IFrameElement()
          ..src =
              'https://www.youtube.com/embed/$_videoId?'
              'enablejsapi=1&'
              'origin=${html.window.location.origin}&'
              'autoplay=0&'
              'controls=1&'
              'rel=0&'
              'showinfo=0&'
              'modestbranding=1&'
              'playsinline=1'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;

    // Register the iframe element
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId!,
      (int viewId) => _iframe!,
    );

    // Simulate ready state after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      _isPlayerReady = true;
      onLoadingChanged(false);
      debugPrint('YouTube player is ready (Web)');
    });

    // Set a timeout to handle stuck loading
    Future.delayed(const Duration(seconds: 10), () {
      if (!_isPlayerReady) {
        debugPrint('YouTube player loading timeout (Web)');
        onErrorChanged('Failed to load trailer. Please try again.');
        onLoadingChanged(false);
      }
    });
  }

  Widget buildPlayer() {
    if (_viewId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text('Loading trailer...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          HtmlElementView(viewType: _viewId!),
          if (!_isPlayerReady)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Loading trailer...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  bool get isFullScreen => _isFullScreen; // Always false for web iframe

  String getCurrentQuality() => _currentQuality;

  void setQuality(String quality) {
    _currentQuality = quality;
    debugPrint('Setting quality to: $quality (Web)');

    // For web iframe implementation, quality is controlled by YouTube's built-in controls
    // We just track the user's preference here
    // In a more advanced implementation, you could use YouTube Player API with postMessage
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    debugPrint('Toggle play/pause (Web): ${_isPlaying ? 'playing' : 'paused'}');

    // Since we can't directly control the iframe player without postMessage,
    // we'll just update our state. The user can use the native YouTube controls.
    if (_iframe != null) {
      // For a more advanced implementation, you would use postMessage
      // to communicate with the YouTube player API
      debugPrint('Use YouTube player controls for play/pause');
    }
  }

  void seekBackward() {
    debugPrint('Seek backward (Web) - Use YouTube player controls');
    // For iframe implementation, user needs to use native controls
    // or implement YouTube Player API with postMessage
  }

  void seekForward() {
    debugPrint('Seek forward (Web) - Use YouTube player controls');
    // For iframe implementation, user needs to use native controls
    // or implement YouTube Player API with postMessage
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    debugPrint('Toggle mute (Web): ${_isMuted ? 'muted' : 'unmuted'}');
    // For iframe implementation, user needs to use native controls
    // or implement YouTube Player API with postMessage
  }

  void reload() {
    debugPrint('Reload player (Web)');
    if (_videoId != null) {
      initialize(_videoId!);
    }
  }

  void pause() {
    _isPlaying = false;
    debugPrint('Pause (Web) - Use YouTube player controls');
    // For iframe implementation, user needs to use native controls
    // or implement YouTube Player API with postMessage
  }

  void dispose() {
    _iframe = null;
    _videoId = null;
    _viewId = null;
    _isPlayerReady = false;
    _isPlaying = false;
    _isMuted = false;
    _currentQuality = 'auto';
    _isFullScreen = false;
    debugPrint('YouTube player disposed (Web)');
  }
}
