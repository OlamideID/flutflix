import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:js' as js;


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

// utils/video_url_helper.dart
class VideoUrlHelper {
  static String getVideoUrl(String movieId) {
    return 'https://vidsrc.icu/embed/movie/$movieId';
  }

  static Future<void> openUrl(String url) async {
    if (kIsWeb) {
      js.context.callMethod('open', [url]);
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}