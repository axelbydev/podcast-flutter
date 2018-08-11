import 'dart:convert';

import 'package:http/http.dart' as http;

class ListenAPIPodcast {
  String id;
  String rss;
  String type;
  String? email;
  String image;
  String title;
  String website;
  String language;
  int itunesId;
  String publisher;
  String thumbnail;
  String description;
  int totalEpisodes;

  ListenAPIPodcast(dynamic lookup)
      : this.id = lookup["id"],
        this.rss = lookup["rss"],
        this.type = lookup["type"],
        this.email = lookup["email"],
        this.image = lookup["image"],
        this.title = lookup["title"],
        this.website = lookup["website"],
        this.language = lookup["language"],
        this.itunesId = lookup["itunes_id"],
        this.publisher = lookup["publisher"],
        this.thumbnail = lookup["thumbnail"],
        this.description = lookup["description"],
        this.totalEpisodes = lookup["total_episodes"];
}

class ListenAPIGenre {
  int id;
  String name;
  int parentId;

  ListenAPIGenre(dynamic lookup)
      : this.id = lookup["id"],
        this.name = lookup["name"],
        this.parentId = lookup["parent_id"];
}

Future<List<ListenAPIGenre>> fetchListenGenres() async {
  String url = "https://listen-api-test.listennotes.com/api/v2/genres?top_level_only=1";
  final response = await http.get(Uri.parse(url));
  dynamic object = json.decode(response.body);
  final list = List.from(object['genres'].map((obj) => ListenAPIGenre(obj)))
      .whereType<ListenAPIGenre>()
      .toList(growable: false);
  list.sort((a, b) => a.name.compareTo(b.name));
  return list;
}

Future<List<ListenAPIPodcast>> fetchListenToplist(int genreId) async {
  try {
    String url =
        "https://listen-api-test.listennotes.com/api/v2/best_podcasts?genre_id=$genreId&page=1&region=us&sort=listen_score&safe_mode=0";
    final response = await http.get(Uri.parse(url));
    dynamic object = json.decode(response.body);
    return List.from(object["podcasts"].map((obj) => ListenAPIPodcast(obj)))
        .whereType<ListenAPIPodcast>()
        .toList(growable: false);
  } catch (e) {
    print(e);
    return [];
  }
}
