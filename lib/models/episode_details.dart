import 'dart:convert';
import 'package:flutter/material.dart';

EpisodeDetails episodeDetailsFromJson(String str) =>
    EpisodeDetails.fromJson(json.decode(str));

String episodeDetailsToJson(EpisodeDetails data) =>
    json.encode(data.toJson());

class EpisodeDetails {
  final String id;
  final DateTime airDate;
  final List<Episode> episodes;
  final String name;
  final String overview;
  final int episodeDetailsId;
  final String posterPath;
  final int seasonNumber;
  final double voteAverage;
  final TmdbId? tmdbId;

  EpisodeDetails({
    required this.id,
    required this.airDate,
    required this.episodes,
    required this.name,
    required this.overview,
    required this.episodeDetailsId,
    required this.posterPath,
    required this.seasonNumber,
    required this.voteAverage,
    this.tmdbId,
  });

  factory EpisodeDetails.fromJson(Map<String, dynamic> json) {
    try {
      return EpisodeDetails(
        id: json["_id"]?.toString() ?? '',
        airDate: DateTime.tryParse(json["air_date"]?.toString() ?? '') ?? DateTime.now(),
        episodes: json["episodes"] != null 
            ? List<Episode>.from(json["episodes"].map((x) => Episode.fromJson(x)))
            : [],
        name: json["name"]?.toString() ?? '',
        overview: json["overview"]?.toString() ?? '',
        episodeDetailsId: json["id"] ?? 0,
        posterPath: json["poster_path"]?.toString() ?? "",
        seasonNumber: json["season_number"] ?? 0,
        voteAverage: (json["vote_average"] ?? 0).toDouble(),
        tmdbId: json["tmdb_id"] != null ? TmdbId.fromJson(json["tmdb_id"]) : null,
      );
    } catch (e) {
      debugPrint('Error parsing EpisodeDetails: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "air_date": airDate.toIso8601String(),
        "episodes": List<dynamic>.from(episodes.map((x) => x.toJson())),
        "name": name,
        "overview": overview,
        "id": episodeDetailsId,
        "poster_path": posterPath,
        "season_number": seasonNumber,
        "vote_average": voteAverage,
        if (tmdbId != null) "tmdb_id": tmdbId!.toJson(),
      };
}

class Episode {
  final DateTime airDate;
  final int episodeNumber;
  final EpisodeType episodeType;
  final int id;
  final String name;
  final String overview;
  final String productionCode;
  final int runtime;
  final int seasonNumber;
  final int showId;
  final String? stillPath;
  final double voteAverage;
  final int voteCount;
  final List<dynamic> crew;
  final List<GuestStar> guestStars;

  Episode({
    required this.airDate,
    required this.episodeNumber,
    required this.episodeType,
    required this.id,
    required this.name,
    required this.overview,
    required this.productionCode,
    required this.runtime,
    required this.seasonNumber,
    required this.showId,
    this.stillPath,
    required this.voteAverage,
    required this.voteCount,
    required this.crew,
    required this.guestStars,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    try {
      return Episode(
        airDate: DateTime.tryParse(json["air_date"]?.toString() ?? '') ?? DateTime.now(),
        episodeNumber: json["episode_number"] ?? 0,
        episodeType: episodeTypeValues.map[json["episode_type"]] ?? EpisodeType.STANDARD,
        id: json["id"] ?? 0,
        name: json["name"]?.toString() ?? 'Unknown Episode',
        overview: json["overview"]?.toString() ?? '',
        productionCode: json["production_code"]?.toString() ?? '',
        runtime: json["runtime"] ?? 0,
        seasonNumber: json["season_number"] ?? 0,
        showId: json["show_id"] ?? 0,
        stillPath: json["still_path"]?.toString(),
        voteAverage: (json["vote_average"] ?? 0).toDouble(),
        voteCount: json["vote_count"] ?? 0,
        crew: json["crew"] != null ? List<dynamic>.from(json["crew"]) : [],
        guestStars: json["guest_stars"] != null 
            ? List<GuestStar>.from(json["guest_stars"].map((x) => GuestStar.fromJson(x)))
            : [],
      );
    } catch (e) {
      debugPrint('Error parsing Episode: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        "air_date": airDate.toIso8601String(),
        "episode_number": episodeNumber,
        "episode_type": episodeTypeValues.reverse[episodeType],
        "id": id,
        "name": name,
        "overview": overview,
        "production_code": productionCode,
        "runtime": runtime,
        "season_number": seasonNumber,
        "show_id": showId,
        "still_path": stillPath,
        "vote_average": voteAverage,
        "vote_count": voteCount,
        "crew": List<dynamic>.from(crew.map((x) => x)),
        "guest_stars": List<dynamic>.from(guestStars.map((x) => x.toJson())),
      };
}

class GuestStar {
  final Character character;
  final String creditId;
  final int order;
  final bool adult;
  final int gender;
  final int id;
  final KnownForDepartment knownForDepartment;
  final String name;
  final String originalName;
  final double popularity;
  final String? profilePath;

  GuestStar({
    required this.character,
    required this.creditId,
    required this.order,
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    this.profilePath,
  });

  factory GuestStar.fromJson(Map<String, dynamic> json) {
    try {
      return GuestStar(
        character: characterValues.map[json["character"]] ?? Character.SELF,
        creditId: json["credit_id"]?.toString() ?? '',
        order: json["order"] ?? 0,
        adult: json["adult"] ?? false,
        gender: json["gender"] ?? 0,
        id: json["id"] ?? 0,
        knownForDepartment: knownForDepartmentValues.map[json["known_for_department"]] ?? KnownForDepartment.ACTING,
        name: json["name"]?.toString() ?? '',
        originalName: json["original_name"]?.toString() ?? '',
        popularity: (json["popularity"] ?? 0).toDouble(),
        profilePath: json["profile_path"]?.toString(),
      );
    } catch (e) {
      debugPrint('Error parsing GuestStar: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        "character": characterValues.reverse[character],
        "credit_id": creditId,
        "order": order,
        "adult": adult,
        "gender": gender,
        "id": id,
        "known_for_department": knownForDepartmentValues.reverse[knownForDepartment],
        "name": name,
        "original_name": originalName,
        "popularity": popularity,
        "profile_path": profilePath,
      };
}

class TmdbId {
  final int id;
  final String imdbId;
  final String freebaseMid;
  final String freebaseId;
  final int tvdbId;
  final int tvrageId;
  final String wikidataId;
  final String facebookId;
  final String instagramId;
  final String twitterId;

  TmdbId({
    required this.id,
    required this.imdbId,
    required this.freebaseMid,
    required this.freebaseId,
    required this.tvdbId,
    required this.tvrageId,
    required this.wikidataId,
    required this.facebookId,
    required this.instagramId,
    required this.twitterId,
  });

  factory TmdbId.fromJson(Map<String, dynamic> json) {
    try {
      return TmdbId(
        id: json["id"] ?? 0,
        imdbId: json["imdb_id"]?.toString() ?? '',
        freebaseMid: json["freebase_mid"]?.toString() ?? '',
        freebaseId: json["freebase_id"]?.toString() ?? '',
        tvdbId: json["tvdb_id"] ?? 0,
        tvrageId: json["tvrage_id"] ?? 0,
        wikidataId: json["wikidata_id"]?.toString() ?? '',
        facebookId: json["facebook_id"]?.toString() ?? '',
        instagramId: json["instagram_id"]?.toString() ?? '',
        twitterId: json["twitter_id"]?.toString() ?? '',
      );
    } catch (e) {
      debugPrint('Error parsing TmdbId: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "imdb_id": imdbId,
        "freebase_mid": freebaseMid,
        "freebase_id": freebaseId,
        "tvdb_id": tvdbId,
        "tvrage_id": tvrageId,
        "wikidata_id": wikidataId,
        "facebook_id": facebookId,
        "instagram_id": instagramId,
        "twitter_id": twitterId,
      };
}

enum EpisodeType { FINALE, STANDARD }

final episodeTypeValues = EnumValues({
  "finale": EpisodeType.FINALE,
  "standard": EpisodeType.STANDARD,
});

enum Character { SELF }

final characterValues = EnumValues({
  "Self": Character.SELF,
});

enum KnownForDepartment { ACTING, DIRECTING, PRODUCTION, WRITING }

final knownForDepartmentValues = EnumValues({
  "Acting": KnownForDepartment.ACTING,
  "Directing": KnownForDepartment.DIRECTING,
  "Production": KnownForDepartment.PRODUCTION,
  "Writing": KnownForDepartment.WRITING,
});

class EnumValues<T> {
  final Map<String, T> map;
  late final Map<T, String> reverseMap;

  EnumValues(this.map) {
    reverseMap = map.map((k, v) => MapEntry(v, k));
  }

  Map<T, String> get reverse => reverseMap;
}