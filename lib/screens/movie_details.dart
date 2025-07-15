// movie_details_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/components/movie_details/trailer_player.dart';
import 'package:netflix/components/movie_details/trailer_section.dart';
import 'package:netflix/components/movie_details/widgets.dart';
import 'package:netflix/components/movies/movie_cast.dart';
import 'package:netflix/components/movies/recommended_section.dart';
import 'package:netflix/components/movies/similar_movies_section.dart';
import 'package:netflix/models/movie_details_model.dart';
import 'package:netflix/providers/providers.dart';
import 'package:netflix/services/api_service.dart';
import 'package:netflix/services/movie_streaming.dart';

final movieDetailsProvider = FutureProvider.family<Moviedetail?, int>((
  ref,
  movieId,
) async {
  final api = ApiService();
  return await api.movieDetails(movieId);
});

class MovieDetailsScreen extends ConsumerStatefulWidget {
  const MovieDetailsScreen({super.key, required this.movieId});
  final int movieId;

  @override
  ConsumerState<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends ConsumerState<MovieDetailsScreen> {
  bool _isLoading = false;
  bool _showTrailer = false;
  String? _errorMessage;
  late final MovieStreamingService _streamingService;
  late final MovieTrailerPlayer _trailerPlayer;

  @override
  void initState() {
    super.initState();
    _streamingService = MovieStreamingService();
    _trailerPlayer = MovieTrailerPlayer(
      onTrailerStarted: () => setState(() => _showTrailer = true),
      onTrailerStopped: () => setState(() => _showTrailer = false),
      onLoadingChanged: (loading) => setState(() => _isLoading = loading),
      onErrorChanged: (error) => setState(() => _errorMessage = error),
    );
  }

  @override
  void dispose() {
    _trailerPlayer.dispose(); // Properly dispose of the YouTube player
    super.dispose();
  }

  Future<void> _startPlaying() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _streamingService.startPlaying(widget.movieId);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error starting video: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playTrailer(String youtubeKey) {
    // The youtubeKey can be either a video ID or a full YouTube URL
    // The MovieTrailerPlayer will handle the conversion
    _trailerPlayer.playTrailer(context, youtubeKey);
  }

  @override
  Widget build(BuildContext context) {
    if (_showTrailer) {
      return _trailerPlayer.buildTrailerPlayer(_errorMessage, _isLoading, context);
    }

    final size = MediaQuery.of(context).size;
    final movieAsync = ref.watch(movieDetailsProvider(widget.movieId));
    final trailerAsync = ref.watch(movieTrailerProvider(widget.movieId));

    return movieAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      data: (movie) {
        if (movie == null) {
          return const Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(size, movie),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MovieDetailsHeader(movie: movie),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                      const SizedBox(height: 24),
                      MovieTrailerSection(
                        trailerAsync: trailerAsync,
                        onTrailerTap: _playTrailer,
                      ),
                      MovieDetailsContent(movie: movie),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: CastSection(movieId: widget.movieId)),
              SliverToBoxAdapter(
                child: SimilarMoviesSection(movieId: widget.movieId),
              ),
              SliverToBoxAdapter(
                child: RecommendedMoviesSection(movieId: widget.movieId),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(Size size, Moviedetail movie) {
    final imagePath = movie.backdropPath ?? movie.posterPath;

    return SliverAppBar(
      expandedHeight: size.height * 0.5,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        style: IconButton.styleFrom(backgroundColor: Colors.black54),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imagePath != null ? "$imageUrl$imagePath" : '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[800],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 50,
                ),
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
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _startPlaying,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.play_arrow, size: 24),
            label: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Watch Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.add, size: 24),
            label: const Text(
              'My List',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}