import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

import '../model/Episode.dart';
import '../model/Podcast.dart';

String? findFirstXMLElementName(String xml) {
  for (var i = 0; i < xml.length; ++i) {
    if (xml[i] != "<") continue;
    if (xml[i + 1] == "?") continue;
    final spaceAt = xml.indexOf(" ", i);
    return xml.substring(i + 1, spaceAt);
  }
  return null;
}

Podcast createRssPodcast(String uri, RssFeed feed) {
  return Podcast(
      feed.title ?? "",
      feed.link ?? "",
      feed.image?.url,
      uri,
      feed.description ?? "",
      feed.items
              ?.map((item) => Episode(
                    item.title ?? "",
                    item.link ?? "",
                    item.content?.value ?? "",
                    item.pubDate ?? DateTime.now(),
                    item.enclosure?.url ?? "",
                  ))
              .toList(growable: false) ??
          []);
}

Podcast createAtomPodcast(String uri, AtomFeed feed) {
  return Podcast(
      feed.title ?? "",
      feed.links?.firstWhereOrNull((link) => link.rel == "alternate")?.href ?? "",
      feed.logo,
      uri,
      feed.subtitle ?? "",
      feed.items
              ?.map((item) => Episode(
                    item.title ?? "",
                    feed.links?.firstWhereOrNull((link) => link.rel == "alternate")?.href ?? "",
                    item.content ?? "",
                    item.published != null ? DateTime.parse(item.published!) : DateTime.now(),
                    feed.links?.firstWhereOrNull((link) => link.rel == "enclosure")?.href ?? "",
                  ))
              .toList(growable: false) ??
          []);
}

Future<Podcast?> fetchRSS(String uri) async {
  final response = await http.get(Uri.parse(uri));
  final firstElementName = findFirstXMLElementName(response.body);
  if (firstElementName == "rss") {
    return createRssPodcast(uri, RssFeed.parse(response.body));
    // return DBProvider.db.saveRssPodcast(uri, RssFeed.parse(response.body));
  }
  if (firstElementName == "atom") {
    return createAtomPodcast(uri, AtomFeed.parse(response.body));
    // return DBProvider.db.saveAtomPodcast(uri, AtomFeed.parse(response.body));
  }
  return null;
}
