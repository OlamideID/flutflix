// To parse this JSON data, do
//
//     final upcomingMovie = upcomingMovieFromJson(jsonString);

import 'dart:convert';

UpcomingMovie upcomingMovieFromJson(String str) =>
    UpcomingMovie.fromJson(json.decode(str));

String upcomingMovieToJson(UpcomingMovie data) => json.encode(data.toJson());

class UpcomingMovie {
  Dates? dates; // Made nullable
  int page;
  List<Result> results;
  int totalPages;
  int totalResults;

  UpcomingMovie({
    this.dates, // Removed required
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory UpcomingMovie.fromJson(Map<String, dynamic> json) => UpcomingMovie(
    dates:
        json["dates"] != null
            ? Dates.fromJson(json["dates"])
            : null, // Safe parsing
    page: json["page"],
    results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    totalPages: json["total_pages"],
    totalResults: json["total_results"],
  );

  Map<String, dynamic> toJson() => {
    "dates": dates?.toJson(), // Safe access
    "page": page,
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "total_pages": totalPages,
    "total_results": totalResults,
  };
}

class Dates {
  DateTime maximum;
  DateTime minimum;

  Dates({required this.maximum, required this.minimum});

  factory Dates.fromJson(Map<String, dynamic> json) => Dates(
    maximum: DateTime.parse(json["maximum"]),
    minimum: DateTime.parse(json["minimum"]),
  );

  Map<String, dynamic> toJson() => {
    "maximum":
        "${maximum.year.toString().padLeft(4, '0')}-${maximum.month.toString().padLeft(2, '0')}-${maximum.day.toString().padLeft(2, '0')}",
    "minimum":
        "${minimum.year.toString().padLeft(4, '0')}-${minimum.month.toString().padLeft(2, '0')}-${minimum.day.toString().padLeft(2, '0')}",
  };
}

class Result {
  bool adult;
  String? backdropPath; // Made nullable - can be null in API
  List<int> genreIds;
  int id;
  OriginalLanguage originalLanguage;
  String originalTitle;
  String overview;
  double popularity;
  String? posterPath; // Made nullable - can be null in API
  DateTime releaseDate;
  String title;
  bool video;
  double voteAverage;
  int voteCount;

  Result({
    required this.adult,
    this.backdropPath, // Removed required
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    this.posterPath, // Removed required
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    adult: json["adult"] ?? false,
    backdropPath: json["backdrop_path"], // Can be null
    genreIds: List<int>.from(json["genre_ids"]?.map((x) => x) ?? []),
    id: json["id"],
    originalLanguage:
        originalLanguageValues.map[json["original_language"]] ??
        OriginalLanguage.EN,
    originalTitle: json["original_title"] ?? "",
    overview: json["overview"] ?? "",
    popularity: (json["popularity"] ?? 0).toDouble(),
    posterPath: json["poster_path"], // Can be null
    releaseDate: DateTime.parse(json["release_date"]),
    title: json["title"] ?? "",
    video: json["video"] ?? false,
    voteAverage: (json["vote_average"] ?? 0).toDouble(),
    voteCount: json["vote_count"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "adult": adult,
    "backdrop_path": backdropPath,
    "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
    "id": id,
    "original_language": originalLanguageValues.reverse[originalLanguage],
    "original_title": originalTitle,
    "overview": overview,
    "popularity": popularity,
    "poster_path": posterPath,
    "release_date":
        "${releaseDate.year.toString().padLeft(4, '0')}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}",
    "title": title,
    "video": video,
    "vote_average": voteAverage,
    "vote_count": voteCount,
  };
}

enum OriginalLanguage { EN, ES, FR, NO }

final originalLanguageValues = EnumValues({
  "en": OriginalLanguage.EN,
  "es": OriginalLanguage.ES,
  "fr": OriginalLanguage.FR,
  "no": OriginalLanguage.NO,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
