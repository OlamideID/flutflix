import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:netflix/models/movie_details_model.dart';

class MyListService {
  static const String _movieIdsKey = 'my_movie_ids';
  static const String _movieDataKey = 'my_movie_data';

  final Box box = Hive.box('myListBox');

  Future<bool> addToMyList(Moviedetail movie) async {
    try {
      final List<String> movieIds =
          box.get(_movieIdsKey, defaultValue: []).cast<String>();
      final Map<String, dynamic> movieData = Map<String, dynamic>.from(
        box.get(_movieDataKey, defaultValue: {}),
      );

      if (movieIds.contains(movie.id.toString())) return false;

      movieIds.add(movie.id.toString());
      movieData[movie.id.toString()] = {
        'id': movie.id,
        'title': movie.title,
        'posterPath': movie.posterPath,
        'backdropPath': movie.backdropPath,
        'overview': movie.overview,
        'voteAverage': movie.voteAverage,
        'releaseDate': movie.releaseDate?.millisecondsSinceEpoch,
        'genres':
            movie.genres.map((g) => {'id': g.id, 'name': g.name}).toList(),
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await box.put(_movieIdsKey, movieIds);
      await box.put(_movieDataKey, movieData);

      return true;
    } catch (e) {
      print('Error adding to my list: $e');
      return false;
    }
  }

  Future<bool> removeFromMyList(int movieId) async {
    try {
      final List<String> movieIds =
          box.get(_movieIdsKey, defaultValue: []).cast<String>();
      final Map<String, dynamic> movieData = Map<String, dynamic>.from(
        box.get(_movieDataKey, defaultValue: {}),
      );

      movieIds.remove(movieId.toString());
      movieData.remove(movieId.toString());

      await box.put(_movieIdsKey, movieIds);
      await box.put(_movieDataKey, movieData);

      return true;
    } catch (e) {
      print('Error removing from my list: $e');
      return false;
    }
  }

  Future<bool> isInMyList(int movieId) async {
    try {
      final List<String> movieIds =
          box.get(_movieIdsKey, defaultValue: []).cast<String>();
      return movieIds.contains(movieId.toString());
    } catch (e) {
      print('Error checking my list: $e');
      return false;
    }
  }

  Future<List<MyListMovie>> getMyList() async {
    try {
      final List<String> movieIds =
          box.get(_movieIdsKey, defaultValue: []).cast<String>();
      final Map<String, dynamic> movieData = Map<String, dynamic>.from(
        box.get(_movieDataKey, defaultValue: {}),
      );

      final List<MyListMovie> movies = [];
      for (final movieId in movieIds) {
        if (movieData.containsKey(movieId)) {
          try {
            movies.add(MyListMovie.fromJson(movieData[movieId]));
          } catch (e) {
            log('Error parsing movie $movieId: $e');
          }
        }
      }

      movies.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return movies;
    } catch (e) {
      log('Error getting my list: $e');
      return [];
    }
  }

  Future<bool> clearMyList() async {
    try {
      await box.delete(_movieIdsKey);
      await box.delete(_movieDataKey);
      return true;
    } catch (e) {
      log('Error clearing my list: $e');
      return false;
    }
  }

  Future<int> getMyListCount() async {
    try {
      final List<String> movieIds =
          box.get(_movieIdsKey, defaultValue: []).cast<String>();
      return movieIds.length;
    } catch (e) {
      log('Error getting my list count: $e');
      return 0;
    }
  }

  Future<bool> cleanupMyList() async {
    try {
      final List<String> movieIds =
          box.get(_movieIdsKey, defaultValue: []).cast<String>();
      final Map<String, dynamic> movieData = Map<String, dynamic>.from(
        box.get(_movieDataKey, defaultValue: {}),
      );

      movieIds.removeWhere((id) => !movieData.containsKey(id));
      final Set<String> idsSet = movieIds.toSet();
      movieData.removeWhere((key, value) => !idsSet.contains(key));

      await box.put(_movieIdsKey, movieIds);
      await box.put(_movieDataKey, movieData);

      return true;
    } catch (e) {
      print('Error cleaning up my list: $e');
      return false;
    }
  }
}

// Simplified model for My List items
class MyListMovie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final DateTime? releaseDate;
  final List<Genre> genres;
  final DateTime addedAt;

  MyListMovie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    this.releaseDate,
    required this.genres,
    required this.addedAt,
  });

  factory MyListMovie.fromJson(Map<String, dynamic> json) {
    try {
      return MyListMovie(
        id: json['id'] ?? 0,
        title: json['title'] ?? 'Unknown Title',
        posterPath: json['posterPath'],
        backdropPath: json['backdropPath'],
        overview: json['overview'] ?? '',
        voteAverage: _parseDouble(json['voteAverage']),
        releaseDate: _parseDateTime(json['releaseDate']),
        genres: _parseGenres(json['genres']),
        addedAt: _parseDateTime(json['addedAt']) ?? DateTime.now(),
      );
    } catch (e) {
      print('Error creating MyListMovie from JSON: $e');
      rethrow;
    }
  }

  // Helper methods for safe parsing
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return null;
      }
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static List<Genre> _parseGenres(dynamic value) {
    if (value == null || value is! List) return [];
    try {
      return (value).map((g) {
        if (g is Map<String, dynamic>) {
          return Genre(id: g['id'] ?? 0, name: g['name'] ?? 'Unknown Genre');
        }
        return Genre(id: 0, name: 'Unknown Genre');
      }).toList();
    } catch (e) {
      print('Error parsing genres: $e');
      return [];
    }
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'posterPath': posterPath,
    'backdropPath': backdropPath,
    'overview': overview,
    'voteAverage': voteAverage,
    'releaseDate': releaseDate?.millisecondsSinceEpoch,
    'genres': genres.map((g) => {'id': g.id, 'name': g.name}).toList(),
    'addedAt': addedAt.millisecondsSinceEpoch,
  };
}
