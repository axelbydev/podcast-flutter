import 'package:flutter/material.dart';
import 'package:podax_flutter/model/db.dart';
import 'package:podax_flutter/services/ListenAPI.dart';
import 'package:podax_flutter/ui/PodcastPage.dart';

import '../model/Podcast.dart';
import '../services/rss.dart';
import 'Chrome.dart';

class ListenPodcastArguments {
  final ListenAPIPodcast podcast;
  ListenPodcastArguments(this.podcast);
}

class ListenPodcastPage extends StatelessWidget {
  static const routeName = "/toplistPodcast";

  Future<Podcast?> getPodcast(ListenPodcastArguments args) async {
    Podcast? podcast = await DBProvider.db.getPodcastByRssUrl(args.podcast.rss);
    if (podcast != null) return podcast;
    return fetchRSS(args.podcast.rss);
  }

  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ListenPodcastArguments;

    return FutureBuilder<Podcast?>(
        future: getPodcast(args),
        builder: (context, snapshot) {
          final data = snapshot.data;
          return Chrome(
            title: data?.title,
            body: data != null
                ? EpisodeList(podcast: data)
                : Center(child: CircularProgressIndicator()),
          );
        });
  }
}
