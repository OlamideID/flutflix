import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflix/features/movie_details/model/movie_details_model.dart';
import 'package:netflix/features/movies/models/movie_credits.dart';
import 'package:netflix/features/movies/models/movie_model.dart';
import 'package:netflix/features/movies/models/movie_trailer.dart';
import 'package:netflix/models/actor_credits.dart';
import 'package:netflix/features/actor_profile/model/actor_profile.dart';
import 'package:netflix/models/airing_today_tv.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:netflix/models/popular_series.dart';
import 'package:netflix/features/movies/models/recommend_movies.dart';
import 'package:netflix/models/recommended_series.dart';
import 'package:netflix/models/series_details.dart';
import 'package:netflix/features/movies/models/similarmovies.dart';
import 'package:netflix/models/similarseries.dart';
import 'package:netflix/features/movies/models/top_rated.dart';
import 'package:netflix/features/movies/models/trending.dart';
import 'package:netflix/models/tv_credits.dart';
import 'package:netflix/models/tv_season_cast.dart';
import 'package:netflix/features/movies/models/up_coming_model.dart';
import 'package:netflix/services/api_service.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final trendingMoviesProvider = FutureProvider<Trending?>((ref) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.trendingMovies();
});

final movieTrailerProvider = FutureProvider.family<MovieTrailer?, int>((
  ref,
  movieId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.fetchMovieTrailer(movieId);
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

final personDetailsProvider = FutureProvider.family<Actorprofile?, int>((
  ref,
  personId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.getPersonDetails(personId);
});

final airingTodaySeriesProvider = FutureProvider<AiringTodaySeries?>((
  ref,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.getAiringTodaySeries();
});

final personCreditsProvider = FutureProvider.family<ActorCredits, int>((
  ref,
  personId,
) async {
  ref.keepAlive();
  final api = ref.read(apiServiceProvider);
  return api.getPersonCredits(personId);
});

