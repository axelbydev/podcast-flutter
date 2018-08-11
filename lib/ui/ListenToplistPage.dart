import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podax_flutter/ui/Chrome.dart';

import '../services/ListenAPI.dart';
import 'ListenPodcastDetail.dart';

class ListenToplistArguments {
  final ListenAPIGenre genre;
  ListenToplistArguments(this.genre);
}

class ListenToplistPage extends StatelessWidget {
  static const routeName = "/toplist";

  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ListenToplistArguments;

    return FutureBuilder<List<ListenAPIPodcast>>(
        future: fetchListenToplist(args.genre.id),
        builder: (context, snapshot) {
          final data = snapshot.data;
          return Chrome(
              title: "Top ${args.genre.name} Podcasts",
              body: data != null
                  ? ListenToplist(podcasts: data)
                  : Center(child: CircularProgressIndicator()));
        });
  }
}

class ListenToplist extends StatelessWidget {
  final List<ListenAPIPodcast> podcasts;

  ListenToplist({Key? key, required this.podcasts}) : super(key: key);

  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: podcasts.length,
        itemBuilder: (BuildContext context, int index) => ListTile(
              leading: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: Image(
                      image: CachedNetworkImageProvider(podcasts[index].thumbnail),
                      fit: BoxFit.cover)),
              title: Text(podcasts[index].title),
              onTap: () => Navigator.pushNamed(context, ListenPodcastPage.routeName,
                  arguments: ListenPodcastArguments(podcasts[index])),
            ));
  }
}
