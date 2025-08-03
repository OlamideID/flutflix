import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netflix/components/movie_details/widgets/mobile.dart'
    if (dart.library.html) 'package:netflix/components/movie_details/web.dart';

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

  String? _extractVideoId(String youtubeKey) {
    final RegExp regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)',
      caseSensitive: false,
    );

    final Match? match = regExp.firstMatch(youtubeKey);
    if (match != null) {
      return match.group(1);
    }

    if (youtubeKey.length == 11 && !youtubeKey.contains('/')) {
      return youtubeKey;
    }

    return null;
  }

  void playTrailer(BuildContext context, String youtubeKey) {
    try {
      debugPrint('Starting trailer playback with key: $youtubeKey');

      onLoadingChanged(true);
      onErrorChanged(null);

      final videoId = _extractVideoId(youtubeKey);
      if (videoId == null || videoId.isEmpty) {
        throw Exception('Invalid YouTube key');
      }

      debugPrint('Extracted video ID: $videoId');

      _platformController.initialize(videoId);

      onTrailerStarted();
    } catch (e) {
      debugPrint('Error starting trailer: $e');
      onErrorChanged('Error starting trailer: $e');
      onLoadingChanged(false);
    }
  }

  Widget buildTrailerPlayer(
    String? errorMessage,
    bool isLoading,
    BuildContext context,
  ) {
    final isFullScreen = false;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Trailer', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              _platformController.dispose();
              onTrailerStopped();
            },
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
                    onPressed: () {
                      _platformController.dispose();
                      onTrailerStopped();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Expanded(child: _platformController.buildPlayer()),
                if (!kIsWeb && !isFullScreen)
                  Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.replay_10,
                            color: Colors.white,
                          ),
                          onPressed: () => _platformController.seekBackward(),
                          tooltip: 'Rewind 10 seconds',
                        ),
                        IconButton(
                          icon: Icon(
                            _platformController.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed:
                              () => _platformController.togglePlayPause(),
                          tooltip:
                              _platformController.isPlaying ? 'Pause' : 'Play',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                          ),
                          onPressed: () => _platformController.seekForward(),
                          tooltip: 'Forward 10 seconds',
                        ),
                        IconButton(
                          icon: Icon(
                            _platformController.isMuted
                                ? Icons.volume_off
                                : Icons.volume_up,
                            color: Colors.white,
                          ),
                          onPressed: () => _platformController.toggleMute(),
                          tooltip:
                              _platformController.isMuted ? 'Unmute' : 'Mute',
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () => _showQualityDialog(context),
                          tooltip: 'Quality Settings',
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () => _platformController.reload(),
                          tooltip: 'Reload',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          if (isLoading)
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

  void _showQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Video Quality',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQualityOption(context, 'Auto', 'auto'),
              _buildQualityOption(context, '1080p', '1080p'),
              _buildQualityOption(context, '720p', '720p'),
              _buildQualityOption(context, '480p', '480p'),
              _buildQualityOption(context, '360p', '360p'),
              _buildQualityOption(context, '240p', '240p'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQualityOption(
    BuildContext context,
    String label,
    String quality,
  ) {
    final currentQuality = _platformController.getCurrentQuality();
    final isSelected = currentQuality == quality;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.red : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? Colors.red : Colors.grey,
      ),
      onTap: () {
        _platformController.setQuality(quality);
        Navigator.of(context).pop();
      },
    );
  }

  void reloadTrailer() {
    _platformController.reload();
  }

  void stopTrailer() {
    _platformController.pause();
  }

  void dispose() {
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    _platformController.dispose();
  }
}
