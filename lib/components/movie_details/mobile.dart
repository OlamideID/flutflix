import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PlatformYouTubePlayerController {
  final ValueChanged<bool> onLoadingChanged;
  final ValueChanged<String?> onErrorChanged;

  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isMuted = false;
  String _currentQuality = 'auto';

  PlatformYouTubePlayerController({
    required this.onLoadingChanged,
    required this.onErrorChanged,
  });

  void initialize(String videoId) {
    dispose();

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
        hideControls: false,
        forceHD: false,
        useHybridComposition: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        showLiveFullscreenButton: false,
      ),
    )..addListener(_playerListener);

    _isPlayerReady = false;
    _isMuted = false;
    _currentQuality = 'auto';

    Future.delayed(const Duration(seconds: 10), () {
      if (_controller != null && !_isPlayerReady) {
        onErrorChanged('Failed to load trailer. Please try again.');
        onLoadingChanged(false);
      }
    });
  }

  void _playerListener() {
    final value = _controller?.value;
    if (value == null) return;

    if (value.hasError) {
      onErrorChanged('Error playing trailer: ${value.errorCode}');
      onLoadingChanged(false);
    }

    if (!_isPlayerReady && value.isReady) {
      _isPlayerReady = true;
      onLoadingChanged(false);
    }

    onLoadingChanged(value.playerState == PlayerState.buffering);
  }

  Widget buildPlayer() {
    if (_controller == null) {
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

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white70,
        ),
        onReady: () {
          _isPlayerReady = true;
          onLoadingChanged(false);
        },
        aspectRatio: 16 / 9,
      ),
      builder: (context, player) => Column(children: [player]),
    );
  }

  bool get isPlaying => _controller?.value.isPlaying ?? false;
  bool get isMuted => _isMuted;
  String getCurrentQuality() => _currentQuality;

  void setQuality(String quality) {
    _currentQuality = quality;
  }

  void togglePlayPause() {
    if (_controller == null) return;
    _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
  }

  void seekBackward() {
    if (_controller == null) return;
    final position = _controller!.value.position;
    _controller!.seekTo(position - const Duration(seconds: 10));
  }

  void seekForward() {
    if (_controller == null) return;
    final position = _controller!.value.position;
    _controller!.seekTo(position + const Duration(seconds: 10));
  }

  void toggleMute() {
    if (_controller == null) return;
    if (_isMuted) {
      _controller!.unMute();
    } else {
      _controller!.mute();
    }
    _isMuted = !_isMuted;
  }

  void reload() {
    _controller?.reload();
    _isMuted = false;
    _currentQuality = 'auto';
  }

  void pause() => _controller?.pause();

  void dispose() {
    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    _controller = null;
    _isPlayerReady = false;
    _isMuted = false;
    _currentQuality = 'auto';
  }
}
