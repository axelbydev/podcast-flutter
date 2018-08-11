class Episode {
  final int id;
  final String title;
  final String link;
  final String content;
  final DateTime pubDate;
  final String enclosure;
  double lastPosition;

  Episode(this.title, this.link, this.content, this.pubDate, this.enclosure)
      : this.id = -1,
        this.lastPosition = 0;

  Episode.fromDB(Map<String, dynamic> obj)
      : id = obj['id'],
        title = obj['title'],
        link = obj['link'],
        content = obj['content'],
        pubDate = DateTime.parse(obj['pub_date']),
        enclosure = obj['enclosure_url'],
        lastPosition = obj['last_position'] ?? 0;

  Map<String, dynamic> toDB(int podcastId) {
    Map<String, dynamic> data = {
      'title': this.title,
      'link': this.link,
      'content': this.content,
      'pub_date': this.pubDate.toIso8601String(),
      'enclosure_url': this.enclosure,
      'last_position': this.lastPosition,
      'podcast_id': podcastId
    };
    if (this.id != -1) data['id'] = this.id;
    return data;
  }
}
