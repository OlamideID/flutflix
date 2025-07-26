import 'package:hive/hive.dart';
import 'package:netflix/models/series_details.dart';

class SeriesFavoritesService {
  static const String _favoritesKey = 'my_series_favorites';
  final Box box = Hive.box('seriesFavoritesBox');

  Future<bool> addToFavorites(SeriesDetails series) async {
    try {
      final List<dynamic> favList = box.get(_favoritesKey, defaultValue: []);

      final exists = favList.any((item) => item['id'] == series.id);
      if (exists) return false;

      favList.add({
        'id': series.id,
        'name': series.name,
        'posterPath': series.posterPath,
        'backdropPath': series.backdropPath,
        'overview': series.overview,
        'voteAverage': series.voteAverage,
        'firstAirDate': series.firstAirDate.toIso8601String(),
        'lastAirDate': series.lastAirDate.toIso8601String(),
        'genres': series.genres.map((g) => {'id': g.id, 'name': g.name}).toList(),
        'numberOfSeasons': series.numberOfSeasons,
        'numberOfEpisodes': series.numberOfEpisodes,
        'status': series.status,
        'addedAt': DateTime.now().toIso8601String(),
      });

      await box.put(_favoritesKey, favList);
      return true;
    } catch (e) {
      print('Error adding series to favorites: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(int seriesId) async {
    try {
      final List<dynamic> favList = box.get(_favoritesKey, defaultValue: []);
      favList.removeWhere((item) => item['id'] == seriesId);
      await box.put(_favoritesKey, favList);
      return true;
    } catch (e) {
      print('Error removing series from favorites: $e');
      return false;
    }
  }

  Future<bool> isInFavorites(int seriesId) async {
    try {
      final List<dynamic> favList = box.get(_favoritesKey, defaultValue: []);
      return favList.any((item) => item['id'] == seriesId);
    } catch (e) {
      print('Error checking series favorites: $e');
      return false;
    }
  }

  Future<List<FavoriteSeries>> getFavorites() async {
    try {
      final List<dynamic> favList = box.get(_favoritesKey, defaultValue: []);
      return favList
          .map((item) => FavoriteSeries.fromJson(Map<String, dynamic>.from(item)))
          .toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    } catch (e) {
      print('Error getting favorite series: $e');
      return [];
    }
  }

  Future<bool> clearFavorites() async {
    try {
      await box.delete(_favoritesKey);
      return true;
    } catch (e) {
      print('Error clearing favorite series: $e');
      return false;
    }
  }
}


// Simplified model for Favorite Series items
class FavoriteSeries {
  final int id;
  final String name;
  final String posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final DateTime firstAirDate;
  final DateTime lastAirDate;
  final List<Genre> genres;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final String status;
  final DateTime addedAt;

  FavoriteSeries({
    required this.id,
    required this.name,
    required this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.genres,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.status,
    required this.addedAt,
  });

  factory FavoriteSeries.fromJson(Map<String, dynamic> json) => FavoriteSeries(
        id: json['id'],
        name: json['name'],
        posterPath: json['posterPath'] ?? '',
        backdropPath: json['backdropPath'],
        overview: json['overview'] ?? '',
        voteAverage: (json['voteAverage'] ?? 0).toDouble(),
        firstAirDate: DateTime.parse(json['firstAirDate']),
        lastAirDate: DateTime.parse(json['lastAirDate']),
        genres: (json['genres'] as List)
            .map((g) => Genre(id: g['id'], name: g['name']))
            .toList(),
        numberOfSeasons: json['numberOfSeasons'] ?? 0,
        numberOfEpisodes: json['numberOfEpisodes'] ?? 0,
        status: json['status'] ?? '',
        addedAt: DateTime.parse(json['addedAt']),
      );
}