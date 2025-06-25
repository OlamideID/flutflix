import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'dart:js' as js;


class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[800],
      width: 120,
      height: 180,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// widgets/common/image_error_widget.dart
class ImageErrorWidget extends StatelessWidget {
  const ImageErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[800],
      width: 120,
      height: 180,
      child: const Icon(Icons.error),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorDisplay extends StatelessWidget {
  final String error;

  const ErrorDisplay({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error: $error'));
  }
}

class NoDataDisplay extends StatelessWidget {
  final String message;

  const NoDataDisplay({super.key, this.message = 'No data available'});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}


// utils/video_url_helper.dart
class VideoUrlHelper {
  static String getVideoUrl(String movieId) {
    return 'https://vidsrc.icu/embed/movie/$movieId';
  }

  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    final launchMode = kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication;

    if (!await launchUrl(
      uri,
      mode: launchMode,
      webOnlyWindowName: '_blank', // Opens in a new tab on web
    )) {
      throw 'Could not launch $url';
    }
  }
}