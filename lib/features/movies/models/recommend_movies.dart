import 'dart:convert';

RecommendedMovies recommendedMoviesFromJson(String str) =>
    RecommendedMovies.fromJson(json.decode(str));

String recommendedMoviesToJson(RecommendedMovies data) =>
    json.encode(data.toJson());

class RecommendedMovies {
  final int page;
  final List<Result> results;
  final int totalPages;
  final int totalResults;

  RecommendedMovies({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory RecommendedMovies.fromJson(Map<String, dynamic> json) =>
      RecommendedMovies(
        page: json["page"] ?? 1,
        results:
            json["results"] != null
                ? List<Result>.from(
                  json["results"].map((x) => Result.fromJson(x)),
                )
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
  final String backdropPath;
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterPath;
  final MediaType mediaType;
  final OriginalLanguage originalLanguage;
  final List<int> genreIds;
  final double popularity;
  final DateTime? releaseDate;
  final bool video;
  final double voteAverage;
  final int voteCount;

  Result({
    required this.adult,
    required this.backdropPath,
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.mediaType,
    required this.originalLanguage,
    required this.genreIds,
    required this.popularity,
    required this.releaseDate,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    adult: json["adult"] ?? false,
    backdropPath: json["backdrop_path"] ?? '',
    id: json["id"] ?? 0,
    title: json["title"] ?? 'Untitled',
    originalTitle: json["original_title"] ?? '',
    overview: json["overview"] ?? '',
    posterPath: json["poster_path"] ?? '',
    mediaType: mediaTypeValues.map[json["media_type"]] ?? MediaType.MOVIE,
    originalLanguage:
        originalLanguageValues.map[json["original_language"]] ??
        OriginalLanguage.EN,
    genreIds: List<int>.from(json["genre_ids"]?.map((x) => x) ?? const []),
    popularity: (json["popularity"] ?? 0).toDouble(),
    releaseDate:
        json["release_date"] != null &&
                json["release_date"].toString().isNotEmpty
            ? DateTime.tryParse(json["release_date"])
            : null,
    video: json["video"] ?? false,
    voteAverage: (json["vote_average"] ?? 0).toDouble(),
    voteCount: json["vote_count"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "adult": adult,
    "backdrop_path": backdropPath,
    "id": id,
    "title": title,
    "original_title": originalTitle,
    "overview": overview,
    "poster_path": posterPath,
    "media_type": mediaTypeValues.reverse[mediaType],
    "original_language": originalLanguageValues.reverse[originalLanguage],
    "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
    "popularity": popularity,
    "release_date":
        releaseDate != null
            ? "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}"
            : null,
    "video": video,
    "vote_average": voteAverage,
    "vote_count": voteCount,
  };
}

enum MediaType { MOVIE }

final mediaTypeValues = EnumValues({"movie": MediaType.MOVIE});

enum OriginalLanguage { EN, SV, TR }

final originalLanguageValues = EnumValues({
  "en": OriginalLanguage.EN,
  "sv": OriginalLanguage.SV,
  "tr": OriginalLanguage.TR,
});

class EnumValues<T> {
  final Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
