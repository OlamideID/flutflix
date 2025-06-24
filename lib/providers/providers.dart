import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/models/movie_model.dart';
import 'package:netflix/models/popular_series.dart';
import 'package:netflix/models/recommend_movies.dart';
import 'package:netflix/models/recommended_series.dart';
import 'package:netflix/models/similarmovies.dart';
import 'package:netflix/models/similarseries.dart';
import 'package:netflix/models/top_rated.dart';
import 'package:netflix/models/trending.dart';
import 'package:netflix/models/up_coming_model.dart';
import 'package:netflix/services/api_service.dart';

// This provider will provide a single ApiService instance throughout the app
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final trendingMoviesProvider = FutureProvider<Trending?>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.trendingMovies();
});

final upcomingMoviesProvider = FutureProvider<UpcomingMovie?>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.upComingMovies();
});

final popularSeriesProvider = FutureProvider<PopularTvSeries?>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.popularSeries();
});

final fetchMoviesProvider = FutureProvider<Movie?>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchMovies();
});

final similarMoviesProvider = FutureProvider.family<Similar?, int>((
  ref,
  movieId,
) async {
  final api = ref.read(apiServiceProvider);
  return await api.getSimilarMovies(movieId);
});

final topRatedMoviesProvider = FutureProvider<Toprated?>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.topRatedMovies();
});

final similarSeriesProvider = FutureProvider.family<SimilarSeries?, int>((
  ref,
  seriesId,
) async {
  final api = ref.read(apiServiceProvider);
  return await api.getSimilarSeries(seriesId);
});

final recommendedSeriesProvider =
    FutureProvider.family<RecommendedSeries?, int>((ref, seriesId) async {
      final api = ref.read(apiServiceProvider);
      return await api.getRecommendedSeries(seriesId);
    });

final recommendedMoviesProvider =
    FutureProvider.family<RecommendedMovies?, int>((ref, seriesId) async {
      final api = ref.read(apiServiceProvider);
      return await api.getRecommendedMovies(seriesId);
    });
