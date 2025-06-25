// To parse this JSON data, do
//
//     final actorprofile = actorprofileFromJson(jsonString);

import 'dart:convert';

Actorprofile actorprofileFromJson(String str) =>
    Actorprofile.fromJson(json.decode(str));

String actorprofileToJson(Actorprofile data) => json.encode(data.toJson());

class Actorprofile {
  bool adult;
  List<String> alsoKnownAs;
  String biography;
  DateTime? birthday; // Made nullable
  dynamic deathday;
  int gender;
  dynamic homepage;
  int id;
  String imdbId;
  String knownForDepartment;
  String name;
  String placeOfBirth;
  double popularity;
  String profilePath;

  Actorprofile({
    required this.adult,
    required this.alsoKnownAs,
    required this.biography,
    this.birthday, // Removed required since it's nullable
    this.deathday,
    required this.gender,
    this.homepage,
    required this.id,
    required this.imdbId,
    required this.knownForDepartment,
    required this.name,
    required this.placeOfBirth,
    required this.popularity,
    required this.profilePath,
  });

  factory Actorprofile.fromJson(Map<String, dynamic> json) {
    try {
      return Actorprofile(
        adult: json["adult"] ?? false,
        alsoKnownAs: json["also_known_as"] != null
            ? List<String>.from(json["also_known_as"].map((x) => x?.toString() ?? ''))
            : [],
        biography: json["biography"] ?? '', // Handle null biography
        birthday: json["birthday"] != null && json["birthday"].toString().isNotEmpty
            ? DateTime.tryParse(json["birthday"])
            : null,
        deathday: json["deathday"],
        gender: json["gender"] ?? 0,
        homepage: json["homepage"],
        id: json["id"] ?? 0,
        imdbId: json["imdb_id"] ?? '',
        knownForDepartment: json["known_for_department"] ?? '',
        name: json["name"] ?? '',
        placeOfBirth: json["place_of_birth"] ?? '',
        popularity: (json["popularity"] ?? 0).toDouble(),
        profilePath: json["profile_path"] ?? '',
      );
    } catch (e) {
      print('Error parsing Actorprofile: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "adult": adult,
    "also_known_as": List<dynamic>.from(alsoKnownAs.map((x) => x)),
    "biography": biography,
    "birthday": birthday != null
        ? "${birthday!.year.toString().padLeft(4, '0')}-${birthday!.month.toString().padLeft(2, '0')}-${birthday!.day.toString().padLeft(2, '0')}"
        : null,
    "deathday": deathday,
    "gender": gender,
    "homepage": homepage,
    "id": id,
    "imdb_id": imdbId,
    "known_for_department": knownForDepartment,
    "name": name,
    "place_of_birth": placeOfBirth,
    "popularity": popularity,
    "profile_path": profilePath,
  };
}