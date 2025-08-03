
// ignore_for_file: unnecessary_null_comparison

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/models/actor_credits.dart';
import 'package:netflix/components/actor_profile/model/actor_profile.dart';
import 'package:netflix/screens/movie_details.dart';
import 'package:netflix/screens/series_detailscreen.dart';
import 'package:netflix/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

final actorProfileProvider = FutureProvider.family<Actorprofile?, int>((
  ref,
  actorId,
) async {
  try {
    final api = ApiService();
    return await api.getPersonDetails(actorId);
  } catch (e) {
    debugPrint('Error fetching actor profile: $e');
    return null;
  }
});

final actorCreditsProvider = FutureProvider.family<ActorCredits?, int>((
  ref,
  actorId,
) async {
  try {
    final api = ApiService();
    return await api.getPersonCredits(actorId);
  } catch (e) {
    debugPrint('Error fetching actor credits: $e');
    return null;
  }
});

class ActorProfileScreen extends ConsumerWidget {
  final int actorId;

  const ActorProfileScreen({super.key, required this.actorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actorProfileAsync = ref.watch(actorProfileProvider(actorId));
    final actorCreditsAsync = ref.watch(actorCreditsProvider(actorId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: actorProfileAsync.when(
              loading:
                  () => const FlexibleSpaceBar(
                    background: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (error, _) => FlexibleSpaceBar(
                    background: Center(child: Text('Error: $error')),
                  ),
              data: (actor) {
                if (actor == null) {
                  return const FlexibleSpaceBar(
                    background: Center(child: Text('No data available')),
                  );
                }
                return FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            actor.profilePath != null
                                ? 'https://image.tmdb.org/t/p/w780${actor.profilePath}'
                                : 'https://via.placeholder.com/780x300?text=No+Image',
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                Container(color: Colors.grey[800]),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.person, size: 100),
                            ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                              Colors.black,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(actor.name),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: actorProfileAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (actor) {
                  if (actor == null) {
                    return const Center(child: Text('No data available'));
                  }
                  return ActorProfileDetails(actor: actor);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Filmography',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          actorCreditsAsync.when(
            loading:
                () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (error, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $error')),
                ),
            data: (credits) {
              if (credits == null || credits.cast.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No credits available')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final credit = credits.cast[index];
                    return CreditCard(credit: credit);
                  }, childCount: credits.cast.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ActorProfileDetails extends StatelessWidget {
  final Actorprofile actor;

  const ActorProfileDetails({super.key, required this.actor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (actor.biography.isNotEmpty) ...[
          Text(
            'Biography',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            actor.biography,
            style: const TextStyle(
              color: Colors.white, // Changed from transparent color
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
        ],
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            // Fixed birthday handling
            if (actor.birthday != null)
              _buildInfoItem(
                context,
                'Born',
                '${actor.birthday!.day}/${actor.birthday!.month}/${actor.birthday!.year}',
              ),
            if (actor.placeOfBirth.isNotEmpty)
              _buildInfoItem(context, 'From', actor.placeOfBirth),
            if (actor.knownForDepartment.isNotEmpty)
              _buildInfoItem(context, 'Department', actor.knownForDepartment),
            _buildInfoItem(
              context,
              'Popularity',
              actor.popularity.toStringAsFixed(1),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (actor.homepage != null &&
            actor.homepage!.toString().isNotEmpty) ...[
          ElevatedButton(
            onPressed: () => launchUrl(Uri.parse(actor.homepage!.toString())),
            child: const Text('Official Website'),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class CreditCard extends StatelessWidget {
  final Cast credit;

  const CreditCard({super.key, required this.credit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (credit.mediaType == 'movie' || credit.title != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailsScreen(movieId: credit.id),
            ),
          );
        } else if (credit.mediaType == 'tv' || credit.name != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeriesDetailsScreen(id: credit.id),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Unknown media type')));
        }
      },

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl:
                    credit.posterPath != null
                        ? 'https://image.tmdb.org/t/p/w500${credit.posterPath}'
                        : 'https://via.placeholder.com/500x750?text=No+Image',
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder:
                    (context, url) => Container(color: Colors.grey[800]),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.error),
                    ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            credit.title ?? credit.name ?? 'Untitled',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (credit.character != null && credit.character!.isNotEmpty)
            Text(
              'as ${credit.character}',
              style: const TextStyle(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                credit.voteAverage.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
