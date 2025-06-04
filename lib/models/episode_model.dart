// To parse this JSON data, do
//
//     final episodes = episodesFromJson(jsonString);

import 'dart:convert';

Episodes episodesFromJson(String str) => Episodes.fromJson(json.decode(str));

String episodesToJson(Episodes data) => json.encode(data.toJson());

class Episodes {
  List<Result> results;
  int id;

  Episodes({required this.results, required this.id});

  factory Episodes.fromJson(Map<String, dynamic> json) => Episodes(
    results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "id": id,
  };
}

class Result {
  String description;
  int episodeCount;
  int groupCount;
  String id;
  String name;
  Network network;
  int type;

  Result({
    required this.description,
    required this.episodeCount,
    required this.groupCount,
    required this.id,
    required this.name,
    required this.network,
    required this.type,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    description: json["description"],
    episodeCount: json["episode_count"],
    groupCount: json["group_count"],
    id: json["id"],
    name: json["name"],
    network: Network.fromJson(json["network"]),
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "description": description,
    "episode_count": episodeCount,
    "group_count": groupCount,
    "id": id,
    "name": name,
    "network": network.toJson(),
    "type": type,
  };
}

class Network {
  int id;
  String logoPath;
  String name;
  String originCountry;

  Network({
    required this.id,
    required this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory Network.fromJson(Map<String, dynamic> json) => Network(
    id: json["id"],
    logoPath: json["logo_path"],
    name: json["name"],
    originCountry: json["origin_country"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "logo_path": logoPath,
    "name": name,
    "origin_country": originCountry,
  };
}
