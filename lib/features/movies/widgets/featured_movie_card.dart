import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/screens/movie_details.dart';

class FeaturedMovieCard extends StatelessWidget {
  final dynamic movie;
  final double screenWidth;

  const FeaturedMovieCard({
    super.key,
    required this.movie,
    required this.screenWidth,
  });

  BoxFit _getBoxFit(double width) {
    if (width < 600) return BoxFit.cover;
    return BoxFit.fitWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background movie image
        Positioned.fill(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(movieId: movie.id),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    "$imageUrl${movie.posterPath}",
                  ),
                  fit: _getBoxFit(screenWidth),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
