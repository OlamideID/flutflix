import 'package:flutter/material.dart';
import 'package:netflix/components/action_button.dart';
import 'package:netflix/helpers/helpers.dart';

class FeaturedMovieActions extends StatelessWidget {
  final dynamic movie;

  const FeaturedMovieActions({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NetflixActionButton(
          onPressed: () async {
            final url = VideoUrlHelper.getVideoUrl(movie.id.toString());
            await VideoUrlHelper.openUrl(url);
          },
          backgroundColor: Colors.white,
          icon: Icons.play_arrow,
          iconColor: Colors.black,
          label: 'Play',
          textColor: Colors.black,
        ),
        const SizedBox(width: 15),
        NetflixActionButton(
          onPressed: () {
            // Add to My List functionality
          },
          backgroundColor: Colors.grey.shade800,
          icon: Icons.add,
          iconColor: Colors.white,
          label: 'My List',
          textColor: Colors.white,
        ),
      ],
    );
  }
}
