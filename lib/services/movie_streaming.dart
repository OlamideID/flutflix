import 'package:url_launcher/url_launcher.dart';

class MovieStreamingService {
  String _buildStreamingUrl(int movieId) {
    return 'https://vidsrc.xyz/embed/movie?tmdb=$movieId&autoplay=1';
  }

  Future<void> startPlaying(int movieId) async {
    final url = _buildStreamingUrl(movieId);
    await _openUrl(url);
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
}