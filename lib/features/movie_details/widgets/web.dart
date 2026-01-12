import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class PlatformYouTubePlayerController {
  final ValueChanged<bool> onLoadingChanged;
  final ValueChanged<String?> onErrorChanged;

  String? _videoId;
  String? _viewId;
  bool _isPlaying = false;
  bool _isMuted = false;
  String _currentQuality = 'auto';

  PlatformYouTubePlayerController({
    required this.onLoadingChanged,
    required this.onErrorChanged,
  });

  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  bool get isFullScreen => false; 

  void initialize(String videoId) {
    dispose();
    _videoId = videoId;
    _viewId = 'yt-$videoId-${DateTime.now().millisecondsSinceEpoch}';

    final iframe = html.IFrameElement()
      ..src = 'https://www.youtube.com/embed/$videoId?enablejsapi=1&rel=0&autoplay=0'
      ..style.border = 'none'
      ..allowFullscreen = true;

    // Register the iframe for the Flutter view
    ui_web.platformViewRegistry.registerViewFactory(_viewId!, (int id) => iframe);

    // Give it a moment to "load" before hiding the spinner
    Future.delayed(const Duration(milliseconds: 800), () {
      onLoadingChanged(false);
    });
  }

  Widget buildPlayer() {
    if (_viewId == null) return const SizedBox.shrink();
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: HtmlElementView(viewType: _viewId!),
    );
  }

  String getCurrentQuality() => _currentQuality;
  void setQuality(String q) => _currentQuality = q;
  
  void togglePlayPause() {} 
  void seekBackward() {}
  void seekForward() {}
  void toggleMute() => _isMuted = !_isMuted;
  void reload() => initialize(_videoId ?? '');
  void pause() => _isPlaying = false;

  void dispose() {
    _viewId = null;
  }
}