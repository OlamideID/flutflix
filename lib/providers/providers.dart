import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/models/actor_credits.dart';
import 'package:netflix/models/actor_profile.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:netflix/models/movie_credits.dart';
import 'package:netflix/models/movie_details_model.dart';
import 'package:netflix/models/movie_model.dart';
import 'package:netflix/models/popular_series.dart';
import 'package:netflix/models/recommend_movies.dart';
import 'package:netflix/models/recommended_series.dart';
import 'package:netflix/models/series_details.dart';
import 'package:netflix/models/similarmovies.dart';
import 'package:netflix/models/similarseries.dart';
import 'package:netflix/models/top_rated.dart';
import 'package:netflix/models/trending.dart';
import 'package:netflix/models/tv_credits.dart';
import 'package:netflix/models/tv_season_cast.dart';
import 'package:netflix/models/up_coming_model.dart';
import 'package:netflix/services/api_service.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(); // No need to pass Dio since it's created internally
});

final trendingMoviesProvider = FutureProvider<Trending?>((ref) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.trendingMovies();
});

final upcomingMoviesProvider = FutureProvider<UpcomingMovie?>((ref) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.upComingMovies();
});

final popularSeriesProvider = FutureProvider<PopularTvSeries?>((ref) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.popularSeries();
});

final fetchMoviesProvider = FutureProvider<Movie?>((ref) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.fetchMovies();
});

final topRatedMoviesProvider = FutureProvider<Toprated?>((ref) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.topRatedMovies();
});

// Movie-related providers
final movieDetailsProvider = FutureProvider.family<Moviedetail?, int>((
  ref,
  movieId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.movieDetails(movieId);
});

final similarMoviesProvider = FutureProvider.family<Similar?, int>((
  ref,
  movieId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.getSimilarMovies(movieId);
});

final recommendedMoviesProvider =
    FutureProvider.family<RecommendedMovies?, int>((ref, movieId) async {
      ref.keepAlive();
      final api = ref.read(apiServiceProvider);
      return api.getRecommendedMovies(movieId);
    });

final movieCreditsProvider = FutureProvider.family<Moviescredits?, int>((
  ref,
  movieId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.getMovieCredits(movieId);
});

// TV Series-related providers
final seriesDetailsProvider = FutureProvider.family<SeriesDetails?, int>((
  ref,
  seriesId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.seriesDetail(seriesId);
});

final similarSeriesProvider = FutureProvider.family<SimilarSeries?, int>((
  ref,
  seriesId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.getSimilarSeries(seriesId);
});

final recommendedSeriesProvider =
    FutureProvider.family<RecommendedSeries?, int>((ref, seriesId) async {
      ref.keepAlive();
      final api = ref.read(apiServiceProvider);
      return api.getRecommendedSeries(seriesId);
    });

final tvSeriesCreditsProvider = FutureProvider.family<Seriescredits?, int>((
  ref,
  tvId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.getTvSeriesCredits(tvId);
});

final seasonCreditsProvider =
    FutureProvider.family<Seasoncast?, ({int seriesId, int seasonNumber})>((
      ref,
      params,
    ) async {
      ref.keepAlive();
      final api = ref.read(apiServiceProvider);
      return api.getSeasonCredits(params.seriesId, params.seasonNumber);
    });

final episodeDetailsProvider =
    FutureProvider.family<EpisodeDetails?, ({int seriesId, int seasonNumber})>((
      ref,
      params,
    ) async {
      ref.keepAlive();
      final api = ref.read(apiServiceProvider);
      return api.getEpisodeDetails(params.seriesId, params.seasonNumber);
    });

final externalIdsProvider = FutureProvider.family<Map<String, dynamic>?, int>((
  ref,
  seriesId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.getExternalIds(seriesId);
});

// Person/actor-related providers
final personDetailsProvider = FutureProvider.family<Actorprofile?, int>((
  ref,
  personId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.getPersonDetails(personId);
});

final personCreditsProvider = FutureProvider.family<ActorCredits, int>((
  ref,
  personId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.getPersonCredits(personId);
});

enum SearchType { movie, tv, person }

final searchTypeProvider = StateProvider<SearchType>((ref) => SearchType.movie);
final searchQueryProvider = StateProvider<String>((ref) => "");

final searchResultsProvider = FutureProvider((ref) async {
  final query = ref.watch(searchQueryProvider);
  final type = ref.watch(searchTypeProvider);
  final api = ref.read(apiServiceProvider);

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
