import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MovieTrailerPlayer {
  final VoidCallback onTrailerStarted;
  final VoidCallback onTrailerStopped;
  final ValueChanged<bool> onLoadingChanged;
  final ValueChanged<String?> onErrorChanged;

  late WebViewController _webViewController;
  bool _isControllerInitialized = false;

  MovieTrailerPlayer({
    required this.onTrailerStarted,
    required this.onTrailerStopped,
    required this.onLoadingChanged,
    required this.onErrorChanged,
  }) {
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.black)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (progress < 100) {
                  onLoadingChanged(true);
                } else {
                  onLoadingChanged(false);
                }
              },
              onPageStarted: (String url) {
                onLoadingChanged(true);
                debugPrint('Page started loading: $url');
              },
              onPageFinished: (String url) {
                onLoadingChanged(false);
                debugPrint('Page finished loading: $url');
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('Web resource error: ${error.description}');
                onErrorChanged('Error loading trailer: ${error.description}');
                onLoadingChanged(false);
              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.contains('youtube.com') ||
                    request.url.contains('youtu.be') ||
                    request.url.contains('googlevideo.com') ||
                    request.url.contains('ytimg.com')) {
                  return NavigationDecision.navigate;
                }
                return NavigationDecision.prevent;
              },
            ),
          );
    _isControllerInitialized = true;
  }

  String _buildTrailerUrl(String youtubeKey) {
    return 'https://www.youtube.com/embed/$youtubeKey'
        '?autoplay=1'
        '&rel=0'
        '&showinfo=0'
        '&controls=1'
        '&modestbranding=1'
        '&fs=1';
  }

  void playTrailer(BuildContext context, String youtubeKey) {
    if (!_isControllerInitialized) {
      onErrorChanged('WebView controller not initialized');
      return;
    }

    try {
      onLoadingChanged(true);

      final trailerUrl = _buildTrailerUrl(youtubeKey);
      debugPrint('Loading trailer URL: $trailerUrl');

      _webViewController.loadRequest(Uri.parse(trailerUrl));

      onTrailerStarted();
      onErrorChanged(null);
    } catch (e) {
      debugPrint('Error starting trailer: $e');
      onErrorChanged('Error starting trailer: $e');
      onLoadingChanged(false);
    }
  }

  void playTrailerExternal(BuildContext context, String youtubeKey) {
    _showTrailerDialog(context, youtubeKey);
  }

  void _showTrailerDialog(BuildContext context, String youtubeKey) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
        automaticallyImplyLeading: false,
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
          else if (_isControllerInitialized)
            WebViewWidget(controller: _webViewController)
          else
            const Center(
              child: Text(
                'Initializing trailer player...',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.red)),
        ],
      ),
    );
  }

  void reloadTrailer() {
    if (_isControllerInitialized) {
      _webViewController.reload();
    }
  }

  void stopTrailer() {
    if (_isControllerInitialized) {
      _webViewController.loadRequest(Uri.parse('about:blank'));
    }
  }
}
