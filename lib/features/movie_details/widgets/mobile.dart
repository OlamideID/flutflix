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

  bool get isFullScreen => _controller?.value.isFullScreen ?? false;

  void initialize(String videoId) {
    dispose();
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        useHybridComposition: true,
      ),
    )..addListener(_playerListener);
  }

  void _playerListener() {
    final value = _controller?.value;
    if (value == null) return;
    if (value.hasError) {
      onErrorChanged('Error: ${value.errorCode}');
      onLoadingChanged(false);
    }
    if (!_isPlayerReady && value.isReady) {
      _isPlayerReady = true;
      onLoadingChanged(false);
    }
    onLoadingChanged(value.playerState == PlayerState.buffering);
  }

  Widget buildPlayer() {
    if (_controller == null) return const Center(child: CircularProgressIndicator());
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) => Column(children: [player]),
    );
  }

  bool get isPlaying => _controller?.value.isPlaying ?? false;
  bool get isMuted => _isMuted;
  String getCurrentQuality() => _currentQuality;
  void setQuality(String quality) => _currentQuality = quality;

  void togglePlayPause() {
    if (_controller == null) return;
    _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
  }

  void seekBackward() => _controller?.seekTo((_controller!.value.position) - const Duration(seconds: 10));
  void seekForward() => _controller?.seekTo((_controller!.value.position) + const Duration(seconds: 10));

  void toggleMute() {
    _isMuted ? _controller?.unMute() : _controller?.mute();
    _isMuted = !_isMuted;
  }

  void reload() => _controller?.reload();
  void pause() => _controller?.pause();
  void dispose() {
    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    _controller = null;
  }
}