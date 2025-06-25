import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/models/movie_credits.dart';
import 'package:netflix/models/movie_model.dart';
import 'package:netflix/models/popular_series.dart';
import 'package:netflix/models/recommend_movies.dart';
import 'package:netflix/models/recommended_series.dart';
import 'package:netflix/models/similarmovies.dart';
import 'package:netflix/models/similarseries.dart';
import 'package:netflix/models/top_rated.dart';
import 'package:netflix/models/trending.dart';
import 'package:netflix/models/tv_credits.dart';
import 'package:netflix/models/tv_season_cast.dart';
import 'package:netflix/models/up_coming_model.dart';
import 'package:netflix/services/api_service.dart';

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

final movieCreditsProvider = FutureProvider.family<Moviescredits?, int>((
  ref,
  movieId,
) async {
  final api = ApiService();
  return await api.getMovieCredits(movieId);
});

final tvSeriesCreditsProvider = FutureProvider.family<Seriescredits?, int>((ref, tvId) async {
  final api = ApiService();
  return await api.getTvSeriesCredits(tvId);
});


final seasonCreditsProvider = FutureProvider.family<Seasoncast?, ({int seriesId, int seasonNumber})>((ref, params) async {
  final api = ApiService();
  return await api.getSeasonCredits(params.seriesId, params.seasonNumber);
});


// Updated enum to include person search
enum SearchType { movie, tv, person }

final searchTypeProvider = StateProvider<SearchType>((ref) => SearchType.movie);
final searchQueryProvider = StateProvider<String>((ref) => "");

final searchResultsProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.read(apiServiceProvider);
  final query = ref.watch(searchQueryProvider);
  final type = ref.watch(searchTypeProvider);

  if (query.trim().isEmpty) return null;

  switch (type) {
    case SearchType.movie:
      return await api.searchMovies(query);
    case SearchType.tv:
      return await api.searchTVSeries(query);
    case SearchType.person:
      return await api.searchPerson(query);
  }
});
