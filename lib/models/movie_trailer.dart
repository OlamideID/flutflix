import 'dart:convert';

import 'package:flutter/material.dart';

MovieTrailer movieTrailerFromJson(String str) =>
    MovieTrailer.fromJson(json.decode(str));

String movieTrailerToJson(MovieTrailer data) => json.encode(data.toJson());

class MovieTrailer {
  final int id;
  final List<VideoResult> results;

  MovieTrailer({required this.id, required this.results});

  factory MovieTrailer.fromJson(Map<String, dynamic> json) {
    try {
      return MovieTrailer(
        id: json["id"] ?? 0,
        results:
            json["results"] != null
                ? List<VideoResult>.from(
                  json["results"].map((x) => VideoResult.fromJson(x)),
                )
                : [],
      );
    } catch (e) {
      debugPrint('Error parsing MovieTrailer: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
  };
}

class VideoResult {
  final String iso6391;
  final String iso31661;
  final String name;
  final String key;
  final DateTime publishedAt;
  final String site;
  final int size;
  final String type;
  final bool official;
  final String id;

  VideoResult({
    required this.iso6391,
    required this.iso31661,
    required this.name,
    required this.key,
    required this.publishedAt,
    required this.site,
    required this.size,
    required this.type,
    required this.official,
    required this.id,
  });

  factory VideoResult.fromJson(Map<String, dynamic> json) {
    try {
      return VideoResult(
        iso6391: json["iso_639_1"]?.toString() ?? '',
        iso31661: json["iso_3166_1"]?.toString() ?? '',
        name: json["name"]?.toString() ?? '',
        key: json["key"]?.toString() ?? '',
        publishedAt:
            DateTime.tryParse(json["published_at"]?.toString() ?? '') ??
            DateTime.now(),
        site: json["site"]?.toString() ?? '',
        size: json["size"] ?? 0,
        type: json["type"]?.toString() ?? '',
        official: json["official"] ?? false,
        id: json["id"]?.toString() ?? '',
      );
    } catch (e) {
      debugPrint('Error parsing VideoResult: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "iso_639_1": iso6391,
    "iso_3166_1": iso31661,
    "name": name,
    "key": key,
    "published_at": publishedAt.toIso8601String(),
    "site": site,
    "size": size,
    "type": type,
    "official": official,
    "id": id,
  };
}
