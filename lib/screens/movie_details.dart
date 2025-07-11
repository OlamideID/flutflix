import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/components/movies/movie_cast.dart';
import 'package:netflix/components/movies/recommended_section.dart';
import 'package:netflix/components/movies/similar_movies_section.dart';
import 'package:netflix/models/movie_details_model.dart';
import 'package:netflix/models/movie_trailer.dart';
import 'package:netflix/providers/providers.dart';
import 'package:netflix/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String _trailerIframeViewType = '';

  @override
  void initState() {
    super.initState();
    _trailerIframeViewType =
        'trailer-player-${DateTime.now().millisecondsSinceEpoch}';
  }

  String _buildStreamingUrl() {
    return 'https://vidsrc.xyz/embed/movie?tmdb=${widget.movieId}&autoplay=1';
  }

  String _buildTrailerUrl(String youtubeKey) {
    return 'https://www.youtube.com/embed/$youtubeKey?autoplay=1&rel=0&showinfo=0&controls=1';
  }

  Future<void> _startPlaying() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final url = _buildStreamingUrl();
      await openUrl(url);
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
    if (kIsWeb) {
      try {
        setState(() {
          _isLoading = true;
        });

        final trailerUrl = _buildTrailerUrl(youtubeKey);
        debugPrint('Loading trailer URL: $trailerUrl');

        ui.platformViewRegistry.registerViewFactory(
          _trailerIframeViewType,
          (int viewId) =>
              html.IFrameElement()
                ..src = trailerUrl
                ..style.border = 'none'
                ..style.width = '100%'
                ..style.height = '100%'
                ..allow =
                    'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
                ..allowFullscreen = true,
        );

        setState(() {
          _showTrailer = true;
          _isLoading = false;
          _errorMessage = null;
        });
      } catch (e) {
        debugPrint('Error starting trailer: $e');
        setState(() {
          _errorMessage = 'Error starting trailer: $e';
          _isLoading = false;
        });
      }
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                'Watch Trailer',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Would you like to watch this trailer on YouTube?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final url = 'https://www.youtube.com/watch?v=$youtubeKey';
                    openUrl(url);
                  },
                  child: const Text(
                    'Open YouTube',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );
    }
  }

  void _stopTrailer() {
    setState(() {
      _showTrailer = false;
    });
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    )) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildTrailerPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Trailer', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _stopTrailer,
            tooltip: 'Close Trailer',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _errorMessage ?? 'Unknown error',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _stopTrailer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            )
          else if (kIsWeb)
            HtmlElementView(viewType: _trailerIframeViewType)
          else
            const Center(
              child: Text(
                'Trailer playback is only supported on web platform',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildTrailerSection(MovieTrailer trailerData) {
    final youtubeTrailers =
        trailerData.results
            .where(
              (video) =>
                  video.site.toLowerCase() == 'youtube' &&
                  video.type.toLowerCase() == 'trailer',
            )
            .toList();

    if (youtubeTrailers.isEmpty) return const SizedBox.shrink();

    youtubeTrailers.sort((a, b) {
      if (a.official && !b.official) return -1;
      if (!a.official && b.official) return 1;
      return b.publishedAt.compareTo(a.publishedAt);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trailers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: youtubeTrailers.length,
            itemBuilder: (context, index) {
              final trailer = youtubeTrailers[index];
              final thumbnailUrl =
                  'https://img.youtube.com/vi/${trailer.key}/hqdefault.jpg';

              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                child: InkWell(
                  onTap: () => _playTrailer(trailer.key),
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
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: thumbnailUrl,
                                  width: double.infinity,
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
                                          Icons.video_library,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ),
                                ),
                              ),
                              const Center(
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                              if (trailer.official)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'OFFICIAL',
                                      style: TextStyle(
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
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trailer.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(trailer.publishedAt),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    }
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showTrailer) {
      return _buildTrailerPlayer();
    }

    final size = MediaQuery.of(context).size;
    final movieAsync = ref.watch(movieDetailsProvider(widget.movieId));
    final trailerAsync = ref.watch(movieTrailerProvider(widget.movieId));

    return movieAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
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

        final imagePath = movie.backdropPath ?? movie.posterPath;

        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
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
                        imageUrl:
                            imagePath != null ? "$imageUrl$imagePath" : '',
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
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${movie.releaseDate?.year ?? 'Unknown'}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${movie.runtime ?? 'N/A'} min',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${movie.voteAverage}/10',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _startPlaying,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.play_arrow, size: 24),
                              label:
                                  _isLoading
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 24),
                              label: const Text(
                                'My List',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      trailerAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (error, _) => const SizedBox.shrink(),
                        data: (trailerData) {
                          if (trailerData == null) {
                            return const SizedBox.shrink();
                          }
                          return _buildTrailerSection(trailerData);
                        },
                      ),
                      if ((movie.tagline?.isNotEmpty ?? false)) ...[
                        Text(
                          '"${movie.tagline}"',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.overview,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (movie.genres.isNotEmpty) ...[
                        const Text(
                          'Genres',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              movie.genres.map((genre) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    genre.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      _buildStatRow('Status', movie.status),
                      _buildStatRow(
                        'Original Language',
                        movie.originalLanguage.toUpperCase(),
                      ),
                      _buildStatRow(
                        'Budget',
                        movie.budget > 0
                            ? '\$${_formatNumber(movie.budget)}'
                            : 'Unknown',
                      ),
                      _buildStatRow(
                        'Revenue',
                        movie.revenue > 0
                            ? '\$${_formatNumber(movie.revenue)}'
                            : 'Unknown',
                      ),
                      _buildStatRow(
                        'Vote Count',
                        '${_formatNumber(movie.voteCount)} votes',
                      ),
                      const SizedBox(height: 24),
                      if (movie.productionCompanies.isNotEmpty) ...[
                        const Text(
                          'Production Companies',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...movie.productionCompanies.map(
                          (company) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '• ${company.name}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (movie.spokenLanguages.isNotEmpty) ...[
                        const Text(
                          'Languages',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              movie.spokenLanguages
                                  .map(
                                    (language) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[600]!,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        language.englishName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
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
}
