import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// FIX: Relative imports prevent "file not found" errors
import 'mobile.dart' if (dart.library.html) 'web.dart';

class MovieTrailerPlayer {
  final VoidCallback onTrailerStarted;
  final VoidCallback onTrailerStopped;
  final ValueChanged<bool> onLoadingChanged;
  final ValueChanged<String?> onErrorChanged;

  late final PlatformYouTubePlayerController _platformController;

  MovieTrailerPlayer({
    required this.onTrailerStarted,
    required this.onTrailerStopped,
    required this.onLoadingChanged,
    required this.onErrorChanged,
  }) {
    _platformController = PlatformYouTubePlayerController(
      onLoadingChanged: onLoadingChanged,
      onErrorChanged: onErrorChanged,
    );
  }

  void playTrailer(BuildContext context, String youtubeKey) {
    onLoadingChanged(true);
    _platformController.initialize(youtubeKey);
    onTrailerStarted();
  }

  Widget buildTrailerPlayer(String? errorMessage, bool isLoading, BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Trailer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _platformController.dispose();
              onTrailerStopped();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _platformController.buildPlayer()),
              // Hide custom controls on Web because Iframe has its own
              if (!kIsWeb && !_platformController.isFullScreen)
                _buildMobileControls(),
            ],
          ),
          if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildMobileControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: const Icon(Icons.replay_10), onPressed: () => _platformController.seekBackward()),
          IconButton(
            icon: Icon(_platformController.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () => _platformController.togglePlayPause(),
          ),
          IconButton(icon: const Icon(Icons.forward_10), onPressed: () => _platformController.seekForward()),
        ],
      ),
    );
  }

  void dispose() {
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    _platformController.dispose();
  }
}