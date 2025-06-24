import 'dart:convert';

SimilarSeries similarSeriesFromJson(String str) =>
    SimilarSeries.fromJson(json.decode(str));

String similarSeriesToJson(SimilarSeries data) => json.encode(data.toJson());

class SimilarSeries {
  final int page;
  final List<Result> results;
  final int totalPages;
  final int totalResults;

  SimilarSeries({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory SimilarSeries.fromJson(Map<String, dynamic> json) => SimilarSeries(
    page: json["page"] ?? 1,
    results:
        json["results"] != null
            ? List<Result>.from(json["results"].map((x) => Result.fromJson(x)))
            : [],
    totalPages: json["total_pages"] ?? 1,
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
  final bool adult;
  final String? backdropPath;
  final List<int> genreIds;
  final int id;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String? posterPath;
  final DateTime? releaseDate;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;

  Result({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    adult: json["adult"] ?? false,
    backdropPath: json["backdrop_path"],
    genreIds: List<int>.from(json["genre_ids"]?.map((x) => x) ?? []),
    id: json["id"] ?? 0,
    originalLanguage: json["original_language"] ?? 'en',
    originalTitle: json["original_title"] ?? '',
    overview: json["overview"] ?? '',
    popularity: (json["popularity"] ?? 0).toDouble(),
    posterPath: json["poster_path"],
    releaseDate:
        json["release_date"] != null && json["release_date"].isNotEmpty
            ? DateTime.tryParse(json["release_date"])
            : null,
    title:
        json["title"] ??
        json["name"] ??
        'Untitled', // Handle both movie and TV series cases
    video: json["video"] ?? false,
    voteAverage: (json["vote_average"] ?? 0).toDouble(),
    voteCount: json["vote_count"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "adult": adult,
    "backdrop_path": backdropPath,
    "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
    "id": id,
    "original_language": originalLanguage,
    "original_title": originalTitle,
    "overview": overview,
    "popularity": popularity,
    "poster_path": posterPath,
    "release_date": releaseDate?.toIso8601String().split('T').first,
    "title": title,
    "video": video,
    "vote_average": voteAverage,
    "vote_count": voteCount,
  };
}
