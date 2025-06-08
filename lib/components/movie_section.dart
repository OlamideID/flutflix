import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/components/movie_list.dart';
import 'package:netflix/components/series_section.dart';
import 'package:netflix/screens/home.dart';

class MovieSection extends ConsumerWidget {
  final String sectionTitle;
  final bool isReverse;
  final FutureProvider provider;

  const MovieSection({
    super.key,
    required this.provider,
    required this.sectionTitle,
    this.isReverse = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMovies = ref.watch(provider);

    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: sectionTitle),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: asyncMovies.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorDisplay(error: e.toString()),
              data: (data) {
                final movies = data?.results ?? [];
                if (movies.isEmpty) {
                  return const Center(
                    child: Text(
                      "No movies found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return MovieList(movies: movies, isReverse: isReverse);
              },
            ),
          ),
        ],
      ),
    );
  }
}
