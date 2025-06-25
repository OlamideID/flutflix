import 'dart:convert';

Seriescredits seriescreditsFromJson(String str) =>
    Seriescredits.fromJson(json.decode(str));

String seriescreditsToJson(Seriescredits data) =>
    json.encode(data.toJson());

class Seriescredits {
  final List<Cast> cast;
  final List<Cast> crew;
  final int id;

  Seriescredits({
    required this.cast,
    required this.crew,
    required this.id,
  });

  factory Seriescredits.fromJson(Map<String, dynamic> json) => Seriescredits(
        cast: (json["cast"] as List<dynamic>?)
                ?.map((x) => Cast.fromJson(x))
                .toList() ??
            [],
        crew: (json["crew"] as List<dynamic>?)
                ?.map((x) => Cast.fromJson(x))
                .toList() ??
            [],
        id: json["id"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "cast": cast.map((x) => x.toJson()).toList(),
        "crew": crew.map((x) => x.toJson()).toList(),
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
  final String? character;
  final String creditId;
  final int? order;
  final String? department;
  final String? job;

  Cast({
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    this.profilePath,
    this.character,
    required this.creditId,
    this.order,
    this.department,
    this.job,
  });

  factory Cast.fromJson(Map<String, dynamic> json) => Cast(
        adult: json["adult"] ?? false,
        gender: json["gender"] ?? 0,
        id: json["id"] ?? 0,
        knownForDepartment: json["known_for_department"] ?? '',
        name: json["name"] ?? '',
        originalName: json["original_name"] ?? '',
        popularity: (json["popularity"] != null)
            ? (json["popularity"] as num).toDouble()
            : 0.0,
        profilePath: json["profile_path"],
        character: json["character"],
        creditId: json["credit_id"] ?? '',
        order: json["order"],
        department: json["department"],
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
        "character": character,
        "credit_id": creditId,
        "order": order,
        "department": department,
        "job": job,
      };
}
