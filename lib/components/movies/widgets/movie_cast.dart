import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/providers/providers.dart';
import 'package:netflix/screens/actor_profile_screen.dart';

class CastSection extends ConsumerWidget {
  final int movieId;

  const CastSection({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditsAsync = ref.watch(movieCreditsProvider(movieId));

    return creditsAsync.when(
      loading:
          () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Failed to load cast',
              style: TextStyle(color: Colors.red[200]),
            ),
          ),
      data: (credits) {
        if (credits == null || credits.cast.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No cast available.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Cast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: credits.cast.length,
                itemBuilder: (context, index) {
                  final actor = credits.cast[index];
                  return InkWell(
                    onTap: () {
                      // Navigate to actor profile screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ActorProfileScreen(actorId: actor.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl:
                                  actor.profilePath != null
                                      ? 'https://image.tmdb.org/t/p/w200${actor.profilePath}'
                                      : 'https://via.placeholder.com/200x300?text=No+Image',
                              height: 120,
                              width: 100,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            actor.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            actor.character ?? '',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
