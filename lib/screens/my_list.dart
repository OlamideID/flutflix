// screens/my_list_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/providers/movie_fav.dart';
import 'package:netflix/providers/series_fav.dart';
import 'package:netflix/screens/movie_details.dart';
import 'package:netflix/screens/series_detailscreen.dart';
import 'package:netflix/services/movie_fav.dart';
import 'package:netflix/services/series_fav.dart';

enum FavoriteType { movies, series }

class MyListScreen extends ConsumerStatefulWidget {
  const MyListScreen({super.key});

  @override
  ConsumerState<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends ConsumerState<MyListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FavoriteType _currentType = FavoriteType.movies;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentType =
            _tabController.index == 0
                ? FavoriteType.movies
                : FavoriteType.series;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'My List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Movies'), Tab(text: 'Series')],
        ),
        actions: [_buildClearAllButton()],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMoviesTab(), _buildSeriesTab()],
      ),
    );
  }

  Widget _buildClearAllButton() {
    if (_currentType == FavoriteType.movies) {
      return Consumer(
        builder: (context, ref, child) {
          final moviesAsync = ref.watch(myListNotifierProvider);
          return moviesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (movies) {
              if (movies.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.grey[800],
                onSelected: (value) async {
                  if (value == 'clear') {
                    _showClearConfirmation(context, ref, FavoriteType.movies);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'clear',
                        child: Row(
                          children: [
                            Icon(Icons.clear_all, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Clear All Movies',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
              );
            },
          );
        },
      );
    } else {
      return Consumer(
        builder: (context, ref, child) {
          final seriesAsync = ref.watch(seriesFavoritesNotifierProvider);
          return seriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (series) {
              if (series.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.grey[800],
                onSelected: (value) async {
                  if (value == 'clear') {
                    _showClearConfirmation(context, ref, FavoriteType.series);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'clear',
                        child: Row(
                          children: [
                            Icon(Icons.clear_all, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Clear All Series',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
              );
            },
          );
        },
      );
    }
  }

  Widget _buildMoviesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final moviesAsync = ref.watch(myListNotifierProvider);
        return moviesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, _) =>
                  _buildErrorState(() => ref.refresh(myListNotifierProvider)),
          data: (movies) {
            if (movies.isEmpty) {
              return _buildEmptyState('movies');
            }
            return _buildMoviesGrid(movies);
          },
        );
      },
    );
  }

  Widget _buildSeriesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final seriesAsync = ref.watch(seriesFavoritesNotifierProvider);
        return seriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, _) => _buildErrorState(
                () => ref.refresh(seriesFavoritesNotifierProvider),
              ),
          data: (series) {
            if (series.isEmpty) {
              return _buildEmptyState('series');
            }
            return _buildSeriesGrid(series);
          },
        );
      },
    );
  }

  Widget _buildErrorState(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'Error loading your list',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'movies' ? Icons.movie_outlined : Icons.tv_outlined,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Text(
            'No $type in your list',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add $type to keep track of what\nyou want to watch',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesGrid(List<MyListMovie> movies) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieCard(context, movie);
      },
    );
  }

  Widget _buildSeriesGrid(List<FavoriteSeries> series) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: series.length,
      itemBuilder: (context, index) {
        final seriesItem = series[index];
        return _buildSeriesCard(context, seriesItem);
      },
    );
  }

  Widget _buildMovieCard(BuildContext context, MyListMovie movie) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movieId: movie.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[900],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: CachedNetworkImage(
                      imageUrl:
                          movie.posterPath != null
                              ? "$imageUrl${movie.posterPath}"
                              : '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _removeMovieFromList(context, movie),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  if (movie.voteAverage > 0)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (movie.releaseDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        movie.releaseDate!.year.toString(),
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesCard(BuildContext context, FavoriteSeries series) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeriesDetailsScreen(id: series.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[900],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: CachedNetworkImage(
                      imageUrl:
                          series.posterPath.isNotEmpty
                              ? "$imageUrl${series.posterPath}"
                              : '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.tv,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _removeSeriesFromList(context, series),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  if (series.voteAverage > 0)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              series.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Series specific badge (seasons count)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${series.numberOfSeasons}S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        series.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      series.firstAirDate.year.toString(),
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeMovieFromList(BuildContext context, MyListMovie movie) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Remove from My List',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Remove "${movie.title}" from your list?',
              style: TextStyle(color: Colors.grey[300]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final notifier = ref.read(myListNotifierProvider.notifier);
                  final success = await notifier.removeMovie(movie.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? '${movie.title} removed from list'
                              : 'Failed to remove',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _removeSeriesFromList(BuildContext context, FavoriteSeries series) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Remove from My List',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Remove "${series.name}" from your list?',
              style: TextStyle(color: Colors.grey[300]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final notifier = ref.read(
                    seriesFavoritesNotifierProvider.notifier,
                  );
                  final success = await notifier.removeSeries(series.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? '${series.name} removed from list'
                              : 'Failed to remove',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showClearConfirmation(
    BuildContext context,
    WidgetRef ref,
    FavoriteType type,
  ) {
    final String itemType = type == FavoriteType.movies ? 'movies' : 'series';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Clear All ${itemType.capitalize()}',
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              'This will remove all $itemType from your list. This action cannot be undone.',
              style: TextStyle(color: Colors.grey[300]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  bool success = false;
                  if (type == FavoriteType.movies) {
                    final notifier = ref.read(myListNotifierProvider.notifier);
                    success = await notifier.clearList();
                  } else {
                    final notifier = ref.read(
                      seriesFavoritesNotifierProvider.notifier,
                    );
                    success = await notifier.clearFavorites();
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'All $itemType cleared from list'
                              : 'Failed to clear $itemType',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
