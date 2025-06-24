import 'package:flutter/material.dart';
import 'package:netflix/components/action_button.dart';
import 'package:netflix/helpers/helpers.dart';

class FeaturedMovieActions extends StatelessWidget {
  final dynamic movie;

  const FeaturedMovieActions({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isSmallScreen = screenWidth < 350;
    final buttonWidth = isSmallScreen ? screenWidth * 0.4 : screenWidth * 0.35;
    final spacing = isSmallScreen ? 8.0 : 15.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 18.0 : 24.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: [
        SizedBox(
          width: buttonWidth,
          child: NetflixActionButton(
            onPressed: () async {
              final url = VideoUrlHelper.getVideoUrl(movie.id.toString());
              await VideoUrlHelper.openUrl(url);
            },
            backgroundColor: Colors.white,
            icon: Icons.play_arrow,
            iconColor: Colors.black,
            label: 'Play',
            textColor: Colors.black,
            textSize: fontSize,
            iconSize: iconSize,
          ),
        ),
        SizedBox(
          width: buttonWidth,
          child: NetflixActionButton(
            onPressed: () {
              // Add to My List functionality
            },
            backgroundColor: Colors.grey.shade800,
            icon: Icons.add,
            iconColor: Colors.white,
            label: 'My List',
            textColor: Colors.white,
            textSize: fontSize,
            iconSize: iconSize,
          ),
        ),
      ],
    );
  }
}
