import 'dart:convert';

Perasonsearch perasonsearchFromJson(String str) =>
    Perasonsearch.fromJson(json.decode(str));

String perasonsearchToJson(Perasonsearch data) => json.encode(data.toJson());

class Perasonsearch {
  final int page;
  final List<Result> results;
  final int totalPages;
  final int totalResults;

  Perasonsearch({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory Perasonsearch.fromJson(Map<String, dynamic> json) => Perasonsearch(
        page: json["page"] ?? 0,
        results: (json["results"] as List<dynamic>?)
                ?.map((x) => Result.fromJson(x))
                .toList() ??
            [],
        totalPages: json["total_pages"] ?? 0,
        totalResults: json["total_results"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "results": results.map((x) => x.toJson()).toList(),
        "total_pages": totalPages,
        "total_results": totalResults,
      };
}

class Result {
  final bool adult;
  final int gender;
  final int id;
  final String knownForDepartment;
  final String name;
  final String originalName;
  final double popularity;
  final String? profilePath;
  final List<KnownFor> knownFor;

  Result({
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    required this.profilePath,
    required this.knownFor,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        adult: json["adult"] ?? false,
        gender: json["gender"] ?? 0,
        id: json["id"] ?? 0,
        knownForDepartment: json["known_for_department"] ?? '',
        name: json["name"] ?? '',
        originalName: json["original_name"] ?? '',
        popularity: (json["popularity"] as num?)?.toDouble() ?? 0.0,
        profilePath: json["profile_path"],
        knownFor: (json["known_for"] as List<dynamic>?)
                ?.map((x) => KnownFor.fromJson(x))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "gender": gender,
        "id": id,
        "known_for_department": knownForDepartment,
        "name": name,
        "original_name": originalName,
        "popularity": popularity,
        "profile_path": profilePath,
        "known_for": knownFor.map((x) => x.toJson()).toList(),
      };
}

class KnownFor {
  final bool adult;
  final String? backdropPath;
  final int id;
  final String? title;
  final String? originalTitle;
  final String overview;
  final String posterPath;
  final String mediaType;
  final String originalLanguage;
  final List<int> genreIds;
  final double popularity;
  final String? releaseDate;
  final bool? video;
  final double voteAverage;
  final int voteCount;
  final String? name;
  final String? originalName;
  final DateTime? firstAirDate;
  final List<String> originCountry;

  KnownFor({
    required this.adult,
    required this.backdropPath,
    required this.id,
    this.title,
    this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.mediaType,
    required this.originalLanguage,
    required this.genreIds,
    required this.popularity,
    this.releaseDate,
    this.video,
    required this.voteAverage,
    required this.voteCount,
    this.name,
    this.originalName,
    this.firstAirDate,
    required this.originCountry,
  });

  factory KnownFor.fromJson(Map<String, dynamic> json) => KnownFor(
        adult: json["adult"] ?? false,
        backdropPath: json["backdrop_path"],
        id: json["id"] ?? 0,
        title: json["title"],
        originalTitle: json["original_title"],
        overview: json["overview"] ?? '',
        posterPath: json["poster_path"] ?? '',
        mediaType: json["media_type"] ?? '',
        originalLanguage: json["original_language"] ?? '',
        genreIds: (json["genre_ids"] as List<dynamic>?)
                ?.map((x) => x as int)
                .toList() ??
            [],
        popularity: (json["popularity"] as num?)?.toDouble() ?? 0.0,
        releaseDate: json["release_date"],
        video: json["video"],
        voteAverage: (json["vote_average"] as num?)?.toDouble() ?? 0.0,
        voteCount: json["vote_count"] ?? 0,
        name: json["name"],
        originalName: json["original_name"],
        firstAirDate: json["first_air_date"] == null
            ? null
            : DateTime.tryParse(json["first_air_date"]),
        originCountry: (json["origin_country"] as List<dynamic>?)
                ?.map((x) => x as String)
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "id": id,
        "title": title,
        "original_title": originalTitle,
        "overview": overview,
        "poster_path": posterPath,
        "media_type": mediaType,
        "original_language": originalLanguage,
        "genre_ids": genreIds,
        "popularity": popularity,
        "release_date": releaseDate,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
        "name": name,
        "original_name": originalName,
        "first_air_date":
            firstAirDate?.toIso8601String().split("T").first, // 'yyyy-MM-dd'
        "origin_country": originCountry,
      };
}
