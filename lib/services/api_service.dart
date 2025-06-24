import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/episode_details.dart';
import 'package:netflix/models/movie_details_model.dart';
import 'package:netflix/models/movie_model.dart';
import 'package:netflix/models/popular_series.dart';
import 'package:netflix/models/recommend_movies.dart';
import 'package:netflix/models/recommended_series.dart';
import 'package:netflix/models/season_details.dart';
import 'package:netflix/models/series_details.dart';
import 'package:netflix/models/similarmovies.dart';
import 'package:netflix/models/similarseries.dart';
import 'package:netflix/models/top_rated.dart';
import 'package:netflix/models/trending.dart';
import 'package:netflix/models/up_coming_model.dart';

var key = "?api_key=$apikey";

class ApiService {
  Future<Movie?> fetchMovies() async {
    try {
      const endPoint = "movie/now_playing";
      final apiUrl = "$baseUrl$endPoint$key";
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("now playing url : $apiUrl");
        return movieFromJson(response.body);
      } else {
        throw Exception('wahala');
      }
    } catch (e) {
      // throw Exception('Error $e');
      print('Wahala $e');
      return null;
    }
  }

  Future<UpcomingMovie?> upComingMovies() async {
    try {
      const endPoint = "movie/upcoming";
      final apiUrl = "$baseUrl$endPoint$key";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        try {
          return upcomingMovieFromJson(response.body);
        } catch (parseError) {
          return null;
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in upComingMovies: $e');
      return null;
    }
  }

  Future<PopularTvSeries?> popularSeries() async {
    try {
      const endPoint = "tv/popular";
      final apiUrl = "$baseUrl$endPoint$key";
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("popular tv series : $apiUrl");
        return popularTvSeriesFromJson(response.body);
      } else {
        throw Exception('wahala');
      }
    } catch (e) {
      // throw Exception('Error $e');
      print('Wahala $e');
      return null;
    }
  }

  Future<SeriesDetails?> seriesDetail(int id) async {
    try {
      final endPoint = "tv/$id";
      final apiUrl = "$baseUrl$endPoint$key";
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("upcoming movie url : $apiUrl");
        return seriesDetailsFromJson(response.body);
      } else {
        throw Exception('wahala');
      }
    } catch (e) {
      // throw Exception('Error $e');
      print('Wahala $e');
      return null;
    }
  }

  Future<Trending?> trendingMovies() async {
    try {
      final endPoint = "trending/movie/day";
      final apiUrl = "$baseUrl$endPoint$key";
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("trending movie url : $apiUrl");
        return trendingFromJson(response.body);
      } else {
        throw Exception('wahala');
      }
    } catch (e) {
      // throw Exception('Error $e');
      print('Wahala $e');
      return null;
    }
  }

  Future<Toprated?> topRatedMovies() async {
    try {
      final endPoint = "movie/top_rated";
      final apiUrl = "$baseUrl$endPoint$key";
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("upcoming movie url : $apiUrl");
        return topratedFromJson(response.body);
      } else {
        throw Exception('wahala');
      }
    } catch (e) {
      // throw Exception('Error $e');
      print('Wahala $e');
      return null;
    }
  }

  Future<Moviedetail?> movieDetails(int movieID) async {
    try {
      final endPoint = "movie/$movieID";
      final apiUrl = "$baseUrl$endPoint$key";
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print("upcoming movie url : $apiUrl");
        return moviedetailsFromJson(response.body);
      } else {
        throw Exception('wahala');
      }
    } catch (e) {
      // throw Exception('Error $e');
      print('Wahala $e');
      return null;
    }
  }

  // Fixed API Service method for getting season details
  Future<Seasondetails?> getSeasonDetails(
    int seriesId,
    int seasonNumber,
  ) async {
    try {
      final url = '$baseUrl/tv/$seriesId/season/$seasonNumber?api_key=$apikey';
      debugPrint('Fetching season details from: $url');
      debugPrint('Series ID: $seriesId, Season Number: $seasonNumber');

      final response = await http.get(Uri.parse(url));

      debugPrint('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('Successfully fetched season details');
        return seasondetailsFromJson(response.body);
      } else {
        debugPrint('Failed response body: ${response.body}');
        throw Exception(
          'Failed to load season details: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching season details: $e');
      return null;
    }
  }

  Future<Similar?> getSimilarMovies(int movieId) async {
    try {
      final endPoint = "movie/$movieId/similar";
      final apiUrl = "$baseUrl$endPoint?api_key=$apikey&language=en-US&page=1";
      print("Fetching similar movies from: $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        try {
          final data = similarFromJson(response.body);
          print("Found ${data.results.length} similar movies");
          return data;
        } catch (e) {
          print('Error parsing similar movies: $e');
          return null;
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error: $e');
      return null;
    }
  }

  Future<SimilarSeries?> getSimilarSeries(int tvSeriesId) async {
    try {
      final endPoint = "tv/$tvSeriesId/similar";
      final apiUrl = "$baseUrl$endPoint?api_key=$apikey&language=en-US&page=1";
      print("Fetching similar series from: $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        try {
          final data = similarSeriesFromJson(response.body);
          print("Found ${data.results.length} similar series");
          return data;
        } catch (e) {
          print('Error parsing similar series: $e');
          return null;
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error: $e');
      return null;
    }
  }

  Future<RecommendedSeries?> getRecommendedSeries(int seriesId) async {
    try {
      final endPoint = "tv/$seriesId/recommendations";
      final apiUrl = "$baseUrl$endPoint?api_key=$apikey";
      print("Fetching recommended series from: $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        try {
          final data = recommendedFromJson(response.body);
          print("Found ${data.results.length} recommended series");
          return data;
        } catch (e) {
          print('Error parsing recommended series: $e');
          return null;
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error: $e');
      return null;
    }
  }

  Future<RecommendedMovies?> getRecommendedMovies(int seriesId) async {
    try {
      final endPoint = "movie/$seriesId/recommendations";
      final apiUrl = "$baseUrl$endPoint?api_key=$apikey";
      print("Fetching recommended series from: $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        try {
          final data = recommendedMoviesFromJson(response.body);
          print("Found ${data.results.length} recommended movies");
          return data;
        } catch (e) {
          print('Error parsing recommended series: $e');
          return null;
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error: $e');
      return null;
    }
  }

  Future<EpisodeDetails?> getEpisodeDetails(
    int seriesId,
    int seasonNumber,
  ) async {
    try {
      final validSeasonNumber = seasonNumber < 1 ? 1 : seasonNumber;

      final url =
          '${baseUrl}tv/$seriesId/season/$validSeasonNumber?api_key=$apikey';
      debugPrint('Fetching episode details from: $url');

      final response = await http.get(Uri.parse(url));

      debugPrint('Response status: ${response.statusCode}');
      // debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final episodeDetails = episodeDetailsFromJson(response.body);
          debugPrint('Successfully parsed episode details');
          return episodeDetails;
        } catch (parseError) {
          debugPrint('Error parsing JSON response: $parseError');
          debugPrint('Raw response: ${response.body}');
          return null;
        }
      } else if (response.statusCode == 404) {
        debugPrint('Season $validSeasonNumber not found for series $seriesId');

        if (validSeasonNumber != 1) {
          debugPrint('Trying fallback to season 1');
          return await getEpisodeDetails(seriesId, 1);
        }

        return null;
      } else {
        debugPrint(
          'Failed to fetch episode details: ${response.statusCode} - ${response.reasonPhrase}',
        );
        debugPrint('Response body: ${response.body}');

        // Parse error response to get more details
        try {
          final errorResponse = json.decode(response.body);
          final errorMessage =
              errorResponse['status_message'] ?? 'Unknown error';
          throw Exception('Failed to load episode details: $errorMessage');
        } catch (e) {
          throw Exception(
            'Failed to load episode details: ${response.statusCode} - ${response.reasonPhrase}',
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching episode details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getExternalIds(int seriesId) async {
    try {
      final url = '${baseUrl}tv/$seriesId/external_ids?api_key=$apikey';
      debugPrint('Fetching external IDs from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('External IDs: $data');
        return data;
      } else {
        debugPrint('Failed to fetch external IDs: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching external IDs: $e');
      return null;
    }
  }
}
