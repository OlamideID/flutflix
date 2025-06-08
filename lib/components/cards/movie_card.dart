import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/helpers/helpers.dart';
import 'package:netflix/screens/movie_details.dart';

class MovieCard extends StatelessWidget {
  final dynamic movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(movieId: movie.id),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child:
              kIsWeb
                  ? Image.network(
                    "$imageUrl${movie.posterPath}",
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const ImageErrorWidget(),
                  )
                  : CachedNetworkImage(
                    imageUrl: "$imageUrl${movie.posterPath}",
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ImagePlaceholder(),
                    errorWidget:
                        (context, url, error) => const ImageErrorWidget(),
                    placeholderFadeInDuration: const Duration(
                      milliseconds: 150,
                    ),
                    fadeInDuration: const Duration(milliseconds: 200),
                    memCacheWidth: 200,
                    memCacheHeight: 300,
                  ),
        ),
      ),
    );
  }
}
