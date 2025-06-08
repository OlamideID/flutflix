import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:netflix/common/utils.dart';
import 'package:netflix/models/episode_model.dart';
import 'package:netflix/models/movie_details_model.dart';
import 'package:netflix/models/movie_model.dart';
import 'package:netflix/models/popular_series.dart';
import 'package:netflix/models/season_details.dart';
import 'package:netflix/models/series_details.dart';
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
        // Add this debug line to see the actual JSON structure
        // print("Raw JSON: ${response.body}");

        // Try parsing with more error handling
        try {
          return upcomingMovieFromJson(response.body);
        } catch (parseError) {
          // print("JSON parsing error: $parseError");
          // // You could try using a generic approach
          // final Map<String, dynamic> json = jsonDecode(response.body);
          // // print("JSON keys: ${json.keys}");
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
  Future<Seasondetails?> getSeasonDetails(int seriesId) async {
    try {
      // Corrected endpoint - this should get TV series details, not episode groups
      final response = await http.get(
        Uri.parse('$baseUrl/tv/$seriesId?api_key=$apikey'),
      );

      if (response.statusCode == 200) {
        json.decode(response.body);
        return seasondetailsFromJson(response.body); // Pass the raw JSON string
      } else {
        throw Exception(
          'Failed to load season details: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching season details: $e');
      return null;
    }
  }

  // Alternative method if you specifically need episode groups
  Future<Seasondetails?> getEpisodeGroups(int seriesId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tv/$seriesId/episode_groups?api_key=$apikey'),
      );

      if (response.statusCode == 200) {
        json.decode(response.body);
        // Note: Episode groups have a different structure than TV series details
        // You might need a different model for this endpoint
        return seasondetailsFromJson(response.body);
      } else {
        throw Exception(
          'Failed to load episode groups: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching episode groups: $e');
      return null;
    }
  }

  Future<Episodes?> getEpisodeDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tv/$id/episode_groups$apikey'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return episodesFromJson(jsonData);
      } else {
        throw Exception('Failed to load season details');
      }
    } catch (e) {
      debugPrint('Error fetching episode details: $e');
      return null;
    }
  }
}
