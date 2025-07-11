import 'dart:convert';

AiringTodaySeries airingTodaySeriesFromJson(String str) =>
    AiringTodaySeries.fromJson(json.decode(str));

String airingTodaySeriesToJson(AiringTodaySeries data) =>
    json.encode(data.toJson());

class AiringTodaySeries {
  final int? page;
  final List<AiringTodayShow>? results;
  final int? totalPages;
  final int? totalResults;

  AiringTodaySeries({
    this.page,
    this.results,
    this.totalPages,
    this.totalResults,
  });

  factory AiringTodaySeries.fromJson(Map<String, dynamic> json) =>
      AiringTodaySeries(
        page: json["page"],
        results: json["results"] == null
            ? null
            : List<AiringTodayShow>.from(
                json["results"].map((x) => AiringTodayShow.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "results":
            results?.map((x) => x.toJson()).toList(),
        "total_pages": totalPages,
        "total_results": totalResults,
      };
}

class AiringTodayShow {
  final bool? adult;
  final String? backdropPath;
  final List<int>? genreIds;
  final int? id;
  final List<String>? originCountry;
  final String? originalLanguage;
  final String? originalName;
  final String? overview;
  final double? popularity;
  final String? posterPath;
  final String? firstAirDate;
  final String? name;
  final double? voteAverage;
  final int? voteCount;

  AiringTodayShow({
    this.adult,
    this.backdropPath,
    this.genreIds,
    this.id,
    this.originCountry,
    this.originalLanguage,
    this.originalName,
    this.overview,
    this.popularity,
    this.posterPath,
    this.firstAirDate,
    this.name,
    this.voteAverage,
    this.voteCount,
  });

  factory AiringTodayShow.fromJson(Map<String, dynamic> json) =>
      AiringTodayShow(
        adult: json["adult"],
        backdropPath: json["backdrop_path"],
        genreIds: json["genre_ids"] == null
            ? null
            : List<int>.from(json["genre_ids"]),
        id: json["id"],
        originCountry: json["origin_country"] == null
            ? null
            : List<String>.from(json["origin_country"]),
        originalLanguage: json["original_language"],
        originalName: json["original_name"],
        overview: json["overview"],
        popularity: (json["popularity"] as num?)?.toDouble(),
        posterPath: json["poster_path"],
        firstAirDate: json["first_air_date"],
        name: json["name"],
        voteAverage: (json["vote_average"] as num?)?.toDouble(),
        voteCount: json["vote_count"],
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "genre_ids": genreIds,
        "id": id,
        "origin_country": originCountry,
        "original_language": originalLanguage,
        "original_name": originalName,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "first_air_date": firstAirDate,
        "name": name,
        "vote_average": voteAverage,
        "vote_count": voteCount,
      };
}
