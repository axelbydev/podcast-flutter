import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../model/Podcast.dart';

class PodcastList extends StatelessWidget {
  final List<Podcast> podcasts;
  final Function handleTap;

  PodcastList({Key? key, required this.podcasts, required this.handleTap}) : super(key: key);

  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: podcasts.length,
      itemBuilder: (BuildContext context, int index) =>
          PodcastListItem(podcast: podcasts[index], handleTap: handleTap),
    );
  }
}

class PodcastListItem extends StatelessWidget {
  final Podcast podcast;
  final Function handleTap;

  PodcastListItem({Key? key, required this.podcast, required this.handleTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
          width: 50.0,
          height: 50.0,
          child:
              Image(image: CachedNetworkImageProvider(podcast.imageUrl ?? ""), fit: BoxFit.cover)),
      title: Text(podcast.title),
      onTap: () => handleTap(podcast),
    );
  }
}
