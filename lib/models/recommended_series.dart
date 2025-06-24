import 'dart:convert';

RecommendedSeries recommendedFromJson(String str) =>
    RecommendedSeries.fromJson(json.decode(str));

String recommendedToJson(RecommendedSeries data) => json.encode(data.toJson());

class RecommendedSeries {
  final int page;
  final List<Result> results;
  final int totalPages;
  final int totalResults;

  RecommendedSeries({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory RecommendedSeries.fromJson(Map<String, dynamic> json) =>
      RecommendedSeries(
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
  final String name;
  final String originalName;
  final String overview;
  final String posterPath;
  final MediaType mediaType;
  final OriginalLanguage originalLanguage;
  final List<int> genreIds;
  final double popularity;
  final DateTime? firstAirDate;
  final double voteAverage;
  final int voteCount;
  final List<OriginCountry> originCountry;

  Result({
    required this.adult,
    required this.backdropPath,
    required this.id,
    required this.name,
    required this.originalName,
    required this.overview,
    required this.posterPath,
    required this.mediaType,
    required this.originalLanguage,
    required this.genreIds,
    required this.popularity,
    this.firstAirDate,
    required this.voteAverage,
    required this.voteCount,
    required this.originCountry,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    adult: json["adult"] ?? false,
    backdropPath: json["backdrop_path"] ?? '',
    id: json["id"] ?? 0,
    name: json["name"] ?? 'Untitled',
    originalName: json["original_name"] ?? '',
    overview: json["overview"] ?? '',
    posterPath: json["poster_path"] ?? '',
    mediaType: mediaTypeValues.map[json["media_type"]] ?? MediaType.TV,
    originalLanguage:
        originalLanguageValues.map[json["original_language"]] ??
        OriginalLanguage.EN,
    genreIds: List<int>.from(json["genre_ids"]?.map((x) => x) ?? []),
    popularity: (json["popularity"] ?? 0).toDouble(),
    firstAirDate:
        json["first_air_date"] != null && json["first_air_date"].isNotEmpty
            ? DateTime.tryParse(json["first_air_date"])
            : null,
    voteAverage: (json["vote_average"] ?? 0).toDouble(),
    voteCount: json["vote_count"] ?? 0,
    originCountry: List<OriginCountry>.from(
      json["origin_country"]?.map(
            (x) => originCountryValues.map[x] ?? OriginCountry.US,
          ) ??
          [OriginCountry.US],
    ),
  );

  Map<String, dynamic> toJson() => {
    "adult": adult,
    "backdrop_path": backdropPath,
    "id": id,
    "name": name,
    "original_name": originalName,
    "overview": overview,
    "poster_path": posterPath,
    "media_type": mediaTypeValues.reverse[mediaType],
    "original_language": originalLanguageValues.reverse[originalLanguage],
    "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
    "popularity": popularity,
    "first_air_date":
        firstAirDate != null
            ? "${firstAirDate!.year.toString().padLeft(4, '0')}-${firstAirDate!.month.toString().padLeft(2, '0')}-${firstAirDate!.day.toString().padLeft(2, '0')}"
            : null,
    "vote_average": voteAverage,
    "vote_count": voteCount,
    "origin_country": List<dynamic>.from(
      originCountry.map((x) => originCountryValues.reverse[x]),
    ),
  };
}

enum MediaType { TV }

final mediaTypeValues = EnumValues({"tv": MediaType.TV});

enum OriginCountry { DK, GB, MX, US }

final originCountryValues = EnumValues({
  "DK": OriginCountry.DK,
  "GB": OriginCountry.GB,
  "MX": OriginCountry.MX,
  "US": OriginCountry.US,
});

enum OriginalLanguage { DA, EN, ES }

final originalLanguageValues = EnumValues({
  "da": OriginalLanguage.DA,
  "en": OriginalLanguage.EN,
  "es": OriginalLanguage.ES,
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
