import 'dart:convert';

Similar similarFromJson(String str) => Similar.fromJson(json.decode(str));
String similarToJson(Similar data) => json.encode(data.toJson());

class Similar {
  int page;
  List<Result> results;
  int totalPages;
  int totalResults;

  Similar({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory Similar.fromJson(Map<String, dynamic> json) => Similar(
    page: json["page"] ?? 0,
    results: List<Result>.from(
      (json["results"] ?? []).map((x) => Result.fromJson(x)),
    ),
    totalPages: json["total_pages"] ?? 0,
    totalResults: json["total_results"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "total_pages": totalPages,
    "total_results": totalResults,
  };
}

class Result {
  bool adult;
  String backdropPath;
  List<int> genreIds;
  int id;
  OriginalLanguage? originalLanguage;
  String originalTitle;
  String overview;
  double popularity;
  String posterPath;
  DateTime? releaseDate;
  String title;
  bool video;
  double voteAverage;
  int voteCount;

  Result({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    adult: json["adult"] ?? false,
    backdropPath: json["backdrop_path"] ?? "",
    genreIds: List<int>.from((json["genre_ids"] ?? []).map((x) => x)),
    id: json["id"] ?? 0,
    originalLanguage: originalLanguageValues.map[json["original_language"]],
    originalTitle: json["original_title"] ?? "",
    overview: json["overview"] ?? "",
    popularity: (json["popularity"] ?? 0).toDouble(),
    posterPath: json["poster_path"] ?? "",
    releaseDate:
        json["release_date"] != null &&
                json["release_date"].toString().isNotEmpty
            ? DateTime.tryParse(json["release_date"])
            : null,
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
    "original_language":
        originalLanguage != null
            ? originalLanguageValues.reverse[originalLanguage]
            : null,
    "original_title": originalTitle,
    "overview": overview,
    "popularity": popularity,
    "poster_path": posterPath,
    "release_date":
        releaseDate != null
            ? "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}"
            : null,
    "title": title,
    "video": video,
    "vote_average": voteAverage,
    "vote_count": voteCount,
  };
}

enum OriginalLanguage { DE, EN, FR }

final originalLanguageValues = EnumValues({
  "de": OriginalLanguage.DE,
  "en": OriginalLanguage.EN,
  "fr": OriginalLanguage.FR,
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
