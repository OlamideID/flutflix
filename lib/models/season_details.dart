// To parse this JSON data, do
//
//     final seasondetails = seasondetailsFromJson(jsonString);

import 'dart:convert';

Seasondetails seasondetailsFromJson(String str) =>
    Seasondetails.fromJson(json.decode(str));

String seasondetailsToJson(Seasondetails data) => json.encode(data.toJson());

class Seasondetails {
  String id;
  DateTime airDate;
  List<Episode> episodes;
  String name;
  String overview;
  int seasondetailsId;
  String posterPath;
  int seasonNumber;
  double voteAverage;

  Seasondetails({
    required this.id,
    required this.airDate,
    required this.episodes,
    required this.name,
    required this.overview,
    required this.seasondetailsId,
    required this.posterPath,
    required this.seasonNumber,
    required this.voteAverage,
  });

  factory Seasondetails.fromJson(Map<String, dynamic> json) => Seasondetails(
    id: json["_id"],
    airDate: DateTime.parse(json["air_date"]),
    episodes: List<Episode>.from(
      json["episodes"].map((x) => Episode.fromJson(x)),
    ),
    name: json["name"],
    overview: json["overview"],
    seasondetailsId: json["id"],
    posterPath: json["poster_path"],
    seasonNumber: json["season_number"],
    voteAverage: json["vote_average"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "air_date":
        "${airDate.year.toString().padLeft(4, '0')}-${airDate.month.toString().padLeft(2, '0')}-${airDate.day.toString().padLeft(2, '0')}",
    "episodes": List<dynamic>.from(episodes.map((x) => x.toJson())),
    "name": name,
    "overview": overview,
    "id": seasondetailsId,
    "poster_path": posterPath,
    "season_number": seasonNumber,
    "vote_average": voteAverage,
  };
}

class Episode {
  DateTime airDate;
  int episodeNumber;
  EpisodeType episodeType;
  int id;
  String name;
  String overview;
  String productionCode;
  int runtime;
  int seasonNumber;
  int showId;
  String stillPath;
  double voteAverage;
  int voteCount;
  List<Crew> crew;
  List<Crew> guestStars;

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
    required this.stillPath,
    required this.voteAverage,
    required this.voteCount,
    required this.crew,
    required this.guestStars,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    airDate: DateTime.parse(json["air_date"]),
    episodeNumber: json["episode_number"],
    episodeType: episodeTypeValues.map[json["episode_type"]]!,
    id: json["id"],
    name: json["name"],
    overview: json["overview"],
    productionCode: json["production_code"],
    runtime: json["runtime"],
    seasonNumber: json["season_number"],
    showId: json["show_id"],
    stillPath: json["still_path"],
    voteAverage: json["vote_average"]?.toDouble(),
    voteCount: json["vote_count"],
    crew: List<Crew>.from(json["crew"].map((x) => Crew.fromJson(x))),
    guestStars: List<Crew>.from(
      json["guest_stars"].map((x) => Crew.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "air_date":
        "${airDate.year.toString().padLeft(4, '0')}-${airDate.month.toString().padLeft(2, '0')}-${airDate.day.toString().padLeft(2, '0')}",
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
    "crew": List<dynamic>.from(crew.map((x) => x.toJson())),
    "guest_stars": List<dynamic>.from(guestStars.map((x) => x.toJson())),
  };
}

class Crew {
  Job? job;
  Department? department;
  String creditId;
  bool adult;
  int gender;
  int id;
  Department knownForDepartment;
  String name;
  String originalName;
  double popularity;
  String? profilePath;
  String? character;
  int? order;

  Crew({
    this.job,
    this.department,
    required this.creditId,
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    required this.profilePath,
    this.character,
    this.order,
  });

  factory Crew.fromJson(Map<String, dynamic> json) => Crew(
    job: jobValues.map[json["job"]]!,
    department: departmentValues.map[json["department"]]!,
    creditId: json["credit_id"],
    adult: json["adult"],
    gender: json["gender"],
    id: json["id"],
    knownForDepartment: departmentValues.map[json["known_for_department"]]!,
    name: json["name"],
    originalName: json["original_name"],
    popularity: json["popularity"]?.toDouble(),
    profilePath: json["profile_path"],
    character: json["character"],
    order: json["order"],
  );

  Map<String, dynamic> toJson() => {
    "job": jobValues.reverse[job],
    "department": departmentValues.reverse[department],
    "credit_id": creditId,
    "adult": adult,
    "gender": gender,
    "id": id,
    "known_for_department": departmentValues.reverse[knownForDepartment],
    "name": name,
    "original_name": originalName,
    "popularity": popularity,
    "profile_path": profilePath,
    "character": character,
    "order": order,
  };
}

enum Department {
  ACTING,
  CAMERA,
  CREW,
  DIRECTING,
  EDITING,
  PRODUCTION,
  WRITING,
}

final departmentValues = EnumValues({
  "Acting": Department.ACTING,
  "Camera": Department.CAMERA,
  "Crew": Department.CREW,
  "Directing": Department.DIRECTING,
  "Editing": Department.EDITING,
  "Production": Department.PRODUCTION,
  "Writing": Department.WRITING,
});

enum Job { DIRECTOR, DIRECTOR_OF_PHOTOGRAPHY, EDITOR, STORY, TELEPLAY, WRITER }

final jobValues = EnumValues({
  "Director": Job.DIRECTOR,
  "Director of Photography": Job.DIRECTOR_OF_PHOTOGRAPHY,
  "Editor": Job.EDITOR,
  "Story": Job.STORY,
  "Teleplay": Job.TELEPLAY,
  "Writer": Job.WRITER,
});

enum EpisodeType { FINALE, STANDARD }

final episodeTypeValues = EnumValues({
  "finale": EpisodeType.FINALE,
  "standard": EpisodeType.STANDARD,
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
