import 'dart:convert';

Moviescredits moviesCreditsFromJson(String str) =>
    Moviescredits.fromJson(json.decode(str));

String moviesCreditsToJson(Moviescredits data) => json.encode(data.toJson());

class Moviescredits {
  final List<Cast> cast;
  final List<Crew> crew;
  final int id;

  Moviescredits({required this.cast, required this.crew, required this.id});

  factory Moviescredits.fromJson(Map<String, dynamic> json) => Moviescredits(
    cast:
        json["cast"] != null
            ? List<Cast>.from(json["cast"].map((x) => Cast.fromJson(x)))
            : <Cast>[],
    crew:
        json["crew"] != null
            ? List<Crew>.from(json["crew"].map((x) => Crew.fromJson(x)))
            : <Crew>[],
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
  final int gender;
  final int id;
  final String knownForDepartment;
  final String name;
  final String originalName;
  final double popularity;
  final String? profilePath;
  final int? castId;
  final String? character;
  final String creditId;
  final int? order;
  final String? mediaType; // <-- Added

  Cast({
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    this.profilePath,
    this.castId,
    this.character,
    required this.creditId,
    this.order,
    this.mediaType, // <-- Added
  });

  factory Cast.fromJson(Map<String, dynamic> json) => Cast(
    adult: json["adult"] ?? false,
    gender: json["gender"] ?? 0,
    id: json["id"] ?? 0,
    knownForDepartment: json["known_for_department"] ?? 'Acting',
    name: json["name"] ?? '',
    originalName: json["original_name"] ?? '',
    popularity: (json["popularity"] ?? 0).toDouble(),
    profilePath: json["profile_path"],
    castId: json["cast_id"],
    character: json["character"],
    creditId: json["credit_id"] ?? '',
    order: json["order"],
    mediaType:
        json.containsKey("media_type") ? json["media_type"] : null, // <-- safe
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
    "cast_id": castId,
    "character": character,
    "credit_id": creditId,
    "order": order,
    "media_type": mediaType, // <-- Added
  };
}

class Crew {
  final bool adult;
  final int gender;
  final int id;
  final String knownForDepartment;
  final String name;
  final String originalName;
  final double popularity;
  final String? profilePath;
  final String creditId;
  final Department? department;
  final String? job;

  Crew({
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    this.profilePath,
    required this.creditId,
    this.department,
    this.job,
  });

  factory Crew.fromJson(Map<String, dynamic> json) => Crew(
    adult: json["adult"] ?? false,
    gender: json["gender"] ?? 0,
    id: json["id"] ?? 0,
    knownForDepartment: json["known_for_department"] ?? '',
    name: json["name"] ?? '',
    originalName: json["original_name"] ?? '',
    popularity: (json["popularity"] ?? 0).toDouble(),
    profilePath: json["profile_path"],
    creditId: json["credit_id"] ?? '',
    department:
        json["department"] != null
            ? departmentValues.map[json["department"]]
            : null,
    job: json["job"],
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
    "credit_id": creditId,
    "department":
        department != null ? departmentValues.reverse[department] : null,
    "job": job,
  };
}

enum Department {
  PRODUCTION,
  WRITING,
  EDITING,
  SOUND,
  DIRECTING,
  ART,
  VISUAL_EFFECTS,
  COSTUME_MAKE_UP,
  CAMERA,
  LIGHTING,
  CREW,
  ACTING,
}

final departmentValues = EnumValues({
  "Production": Department.PRODUCTION,
  "Writing": Department.WRITING,
  "Editing": Department.EDITING,
  "Sound": Department.SOUND,
  "Directing": Department.DIRECTING,
  "Art": Department.ART,
  "Visual Effects": Department.VISUAL_EFFECTS,
  "Costume & Make-Up": Department.COSTUME_MAKE_UP,
  "Camera": Department.CAMERA,
  "Lighting": Department.LIGHTING,
  "Crew": Department.CREW,
  "Acting": Department.ACTING,
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
