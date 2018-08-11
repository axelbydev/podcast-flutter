import 'Episode.dart';

class Podcast {
  final int id;
  final String title;
  final String link;
  final String? imageUrl;
  final String? rssUrl;
  final String description;
  final List<Episode> episodes;

  Podcast(this.title, this.link, this.imageUrl, this.rssUrl, this.description, this.episodes)
      : this.id = -1;

  Podcast.fromDB(Map<String, dynamic> obj, List<Map<String, dynamic>>? episodeObjs)
      : id = obj['id'],
        link = obj['link'],
        title = obj['title'],
        imageUrl = obj['image_url'],
        rssUrl = obj['rss_url'],
        description = obj['description'],
        episodes = episodeObjs?.map((e) => Episode.fromDB(e)).toList() ?? [];

  Map<String, dynamic> toDB() {
    Map<String, dynamic> data = {
      'link': this.link,
      'title': this.title,
      'image_url': this.imageUrl,
      'rss_url': this.rssUrl,
      'description': this.description,
    };
    if (this.id != -1) data["id"] = this.id;
    return data;
  }
}
