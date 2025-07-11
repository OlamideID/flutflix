import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/actor_credits.dart';
import 'package:netflix/models/actor_profile.dart';
import 'package:netflix/models/airing_today_tv.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:netflix/models/movie_credits.dart';
import 'package:netflix/models/movie_details_model.dart';
import 'package:netflix/models/movie_model.dart';
import 'package:netflix/models/movie_trailer.dart';
import 'package:netflix/models/person_search.dart';
import 'package:netflix/models/popular_series.dart';
import 'package:netflix/models/recommend_movies.dart';
import 'package:netflix/models/recommended_series.dart';
import 'package:netflix/models/search_movie.dart';
import 'package:netflix/models/search_tv.dart';
import 'package:netflix/models/series_details.dart';
import 'package:netflix/models/similarmovies.dart';
import 'package:netflix/models/similarseries.dart';
import 'package:netflix/models/top_rated.dart';
import 'package:netflix/models/trending.dart';
import 'package:netflix/models/tv_credits.dart';
import 'package:netflix/models/tv_season_cast.dart';
import 'package:netflix/models/up_coming_model.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ) {
    _dio.interceptors.addAll([
      DioCacheInterceptor(
        options: CacheOptions(
          store: MemCacheStore(),
          policy: CachePolicy.forceCache,
          maxStale: const Duration(hours: 1),
          priority: CachePriority.normal,
          keyBuilder: CacheOptions.defaultCacheKeyBuilder,
          allowPostMethod: false,
        ),
      ),
      LogInterceptor(request: true, responseBody: true, requestBody: true),
    ]);
  }

  // Universal response parser helper
  T _parseResponse<T>(dynamic responseData, T Function(String) parser) {
    if (responseData is String) {
      return parser(responseData);
    } else {
      return parser(json.encode(responseData));
    }
  }

  Future<Movie?> fetchMovies() async {
    try {
      final response = await _dio.get(
        'movie/now_playing',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, movieFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching movies: ${e.message}');
      return null;
    }
  }

  Future<UpcomingMovie?> upComingMovies() async {
    try {
      final response = await _dio.get(
        'movie/upcoming',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, upcomingMovieFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching upcoming movies: ${e.message}');
      return null;
    }
  }

  Future<SearchMovie?> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        'search/movie',
        queryParameters: {'api_key': apikey, 'query': query},
      );
      return _parseResponse(response.data, searchMovieFromJson);
    } on DioException catch (e) {
      debugPrint('Error searching movies: ${e.message}');
      return null;
    }
  }

  Future<SearchTV?> searchTVSeries(String query) async {
    try {
      final response = await _dio.get(
        'search/tv',
        queryParameters: {'api_key': apikey, 'query': query},
      );
      return _parseResponse(response.data, searchTVFromJson);
    } on DioException catch (e) {
      debugPrint('Error searching TV: ${e.message}');
      return null;
    }
  }

  Future<PopularTvSeries?> popularSeries() async {
    try {
      final response = await _dio.get(
        'tv/popular',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, popularTvSeriesFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching popular series: ${e.message}');
      return null;
    }
  }

  Future<AiringTodaySeries?> getAiringTodaySeries() async {
  try {
    final response = await _dio.get(
      'tv/airing_today',
      queryParameters: {'api_key': apikey},
    );
    return _parseResponse(response.data, airingTodaySeriesFromJson);
  } on DioException catch (e) {
    debugPrint('Error fetching airing today series: ${e.message}');
    return null;
  }
}

  Future<SeriesDetails?> seriesDetail(int id) async {
    try {
      final response = await _dio.get(
        'tv/$id',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, seriesDetailsFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching series details: ${e.message}');
      return null;
    }
  }

  Future<Trending?> trendingMovies() async {
    try {
      final response = await _dio.get(
        'trending/movie/day',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, trendingFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching trending movies: ${e.message}');
      return null;
    }
  }

  Future<Toprated?> topRatedMovies() async {
    try {
      final response = await _dio.get(
        'movie/top_rated',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, topratedFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching top rated movies: ${e.message}');
      return null;
    }
  }

  Future<Moviedetail?> movieDetails(int movieID) async {
    try {
      final response = await _dio.get(
        'movie/$movieID',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, moviedetailsFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching movie details: ${e.message}');
      return null;
    }
  }

  Future<Actorprofile?> getPersonDetails(int personId) async {
    try {
      final response = await _dio.get(
        'person/$personId',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, actorprofileFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching person details: ${e.message}');
      return null;
    }
  }

  Future<ActorCredits> getPersonCredits(int personId) async {
    try {
      final response = await _dio.get(
        'person/$personId/combined_credits',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, actorcreditsfromjson);
    } on DioException catch (e) {
      debugPrint('Error fetching person credits: ${e.message}');
      rethrow;
    }
  }

  Future<Moviescredits?> getMovieCredits(int movieId) async {
    try {
      final response = await _dio.get(
        'movie/$movieId/credits',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, moviesCreditsFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching movie credits: ${e.message}');
      return null;
    }
  }

  Future<Seasoncast?> getSeasonCredits(int seriesId, int seasonNumber) async {
    try {
      final response = await _dio.get(
        'tv/$seriesId/season/$seasonNumber/credits',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, seasoncastFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching season credits: ${e.message}');
      return null;
    }
  }

  Future<Seriescredits?> getTvSeriesCredits(int tvId) async {
    try {
      final response = await _dio.get(
        'tv/$tvId/credits',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, seriescreditsFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching TV credits: ${e.message}');
      return null;
    }
  }

  Future<Perasonsearch?> searchPerson(String query) async {
    try {
      final response = await _dio.get(
        'search/person',
        queryParameters: {'api_key': apikey, 'query': query},
      );
      return _parseResponse(response.data, perasonsearchFromJson);
    } on DioException catch (e) {
      debugPrint('Error searching person: ${e.message}');
      return null;
    }
  }

  Future<Similar?> getSimilarMovies(int movieId) async {
    try {
      final response = await _dio.get(
        'movie/$movieId/similar',
        queryParameters: {'api_key': apikey, 'language': 'en-US', 'page': 1},
      );
      return _parseResponse(response.data, similarFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching similar movies: ${e.message}');
      return null;
    }
  }

  Future<SimilarSeries?> getSimilarSeries(int tvSeriesId) async {
    try {
      final response = await _dio.get(
        'tv/$tvSeriesId/similar',
        queryParameters: {'api_key': apikey, 'language': 'en-US', 'page': 1},
      );
      return _parseResponse(response.data, similarSeriesFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching similar series: ${e.message}');
      return null;
    }
  }

  Future<RecommendedSeries?> getRecommendedSeries(int seriesId) async {
    try {
      final response = await _dio.get(
        'tv/$seriesId/recommendations',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, recommendedFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching recommended series: ${e.message}');
      return null;
    }
  }

  Future<RecommendedMovies?> getRecommendedMovies(int movieId) async {
    try {
      final response = await _dio.get(
        'movie/$movieId/recommendations',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, recommendedMoviesFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching recommended movies: ${e.message}');
      return null;
    }
  }

  Future<EpisodeDetails?> getEpisodeDetails(
    int seriesId,
    int seasonNumber,
  ) async {
    try {
      final response = await _dio.get(
        'tv/$seriesId/season/$seasonNumber',
        queryParameters: {'api_key': apikey},
      );
      return _parseResponse(response.data, episodeDetailsFromJson);
    } on DioException catch (e) {
      debugPrint('Error fetching episode details: ${e.message}');
      return null;
    }
  }

  
  Future<MovieTrailer?> fetchMovieTrailer(int movieID) async {
  try {
    final response = await _dio.get(
      'movie/$movieID/videos',
      queryParameters: {'api_key': apikey},
    );
    return _parseResponse(response.data, movieTrailerFromJson);
  } on DioException catch (e) {
    debugPrint('Error fetching movie trailer: ${e.message}');
    return null;
  }
}

  Future<Map<String, dynamic>?> getExternalIds(int seriesId) async {
    try {
      final response = await _dio.get(
        'tv/$seriesId/external_ids',
        queryParameters: {'api_key': apikey},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('Error fetching external IDs: ${e.message}');
      return null;
    }
  }



}



