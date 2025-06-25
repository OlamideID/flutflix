import 'dart:convert';

ActorCredits actorcreditsfromjson(String str) =>
    ActorCredits.fromJson(json.decode(str));

String actorCreditsToJson(ActorCredits data) => json.encode(data.toJson());

class ActorCredits {
  final List<Cast> cast;
  final List<Cast> crew;
  final int id;

  ActorCredits({required this.cast, required this.crew, required this.id});

  factory ActorCredits.fromJson(Map<String, dynamic> json) => ActorCredits(
    cast:
        json["cast"] != null
            ? List<Cast>.from(json["cast"].map((x) => Cast.fromJson(x)))
            : [],
    crew:
        json["crew"] != null
            ? List<Cast>.from(json["crew"].map((x) => Cast.fromJson(x)))
            : [],
    id: json["id"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "cast": List<dynamic>.from(cast.map((x) => x.toJson())),
    "crew": List<dynamic>.from(crew.map((x) => x.toJson())),
    "id": id,
  };
}

class Cast {
  final bool adult;
  final String? backdropPath;
  final List<int> genreIds;
  final int id;
  final String? originalLanguage; // Changed from enum to String
  final String? originalTitle;
  final String overview;
  final double popularity;
  final String? posterPath;
  final String? releaseDate;
  final String? title;
  final bool? video;
  final double voteAverage;
  final int voteCount;
  final String? character;
  final String creditId;
  final int? order;
  final String? mediaType; // Changed from enum to String
  final List<String>? originCountry; // Changed from enum to String
  final String? originalName;
  final String? firstAirDate;
  final String? name;
  final int? episodeCount;
  final DateTime? firstCreditAirDate;
  final String? department; // Changed from enum to String
  final String? job; // Changed from enum to String

  Cast({
    required this.adult,
    this.backdropPath,
    required this.genreIds,
    required this.id,
    this.originalLanguage,
    this.originalTitle,
    required this.overview,
    required this.popularity,
    this.posterPath,
    this.releaseDate,
    this.title,
    this.video,
    required this.voteAverage,
    required this.voteCount,
    this.character,
    required this.creditId,
    this.order,
    this.mediaType,
    this.originCountry,
    this.originalName,
    this.firstAirDate,
    this.name,
    this.episodeCount,
    this.firstCreditAirDate,
    this.department,
    this.job,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    try {
      return Cast(
        adult: json["adult"] ?? false,
        backdropPath: json["backdrop_path"],
        genreIds:
            json["genre_ids"] != null
                ? List<int>.from(json["genre_ids"].map((x) => x ?? 0))
                : [],
        id: json["id"] ?? 0,
        originalLanguage: json["original_language"], // Direct string assignment
        originalTitle: json["original_title"],
        overview: json["overview"] ?? '',
        popularity: (json["popularity"] ?? 0).toDouble(),
        posterPath: json["poster_path"],
        releaseDate: json["release_date"],
        title: json["title"],
        video: json["video"],
        voteAverage: (json["vote_average"] ?? 0).toDouble(),
        voteCount: json["vote_count"] ?? 0,
        character: json["character"],
        creditId: json["credit_id"] ?? '',
        order: json["order"],
        mediaType: json["media_type"], // Direct string assignment
        originCountry:
            json["origin_country"] != null
                ? List<String>.from(
                  json["origin_country"].map((x) => x?.toString() ?? ''),
                )
                : null,
        originalName: json["original_name"],
        firstAirDate: json["first_air_date"],
        name: json["name"],
        episodeCount: json["episode_count"],
        firstCreditAirDate:
            json["first_credit_air_date"] != null
                ? DateTime.tryParse(json["first_credit_air_date"])
                : null,
        department: json["department"], // Direct string assignment
        job: json["job"], // Direct string assignment
      );
    } catch (e) {
      print('Error parsing Cast from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

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
    "release_date": releaseDate,
    "title": title,
    "video": video,
    "vote_average": voteAverage,
    "vote_count": voteCount,
    "character": character,
    "credit_id": creditId,
    "order": order,
    "media_type": mediaType,
    "origin_country": originCountry,
    "original_name": originalName,
    "first_air_date": firstAirDate,
    "name": name,
    "episode_count": episodeCount,
    "first_credit_air_date": firstCreditAirDate?.toIso8601String(),
    "department": department,
    "job": job,
  };
}
