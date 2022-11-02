import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podax_flutter/model/PlaylistCubit.dart';
import 'package:podax_flutter/model/PlaylistEntry.dart';
import 'package:podax_flutter/model/db.dart';
import 'package:podax_flutter/services/rss.dart';

import '../model/Episode.dart';
import '../model/Podcast.dart';
import '../model/SubscriptionsCubit.dart';
import 'Chrome.dart';

class PodcastPageArguments {
  final int podcastId;
  PodcastPageArguments(this.podcastId);
}

class PodcastPage extends StatelessWidget {
  static const routeName = "/podcast";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as PodcastPageArguments;

    return FutureBuilder<Podcast?>(
        future: DBProvider.db.getPodcast(args.podcastId),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final rssUrl = data?.rssUrl;
          return Chrome(
            title: data?.title,
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () async {
                      if (rssUrl != null) {
                        final podcast = await fetchRSS(rssUrl);
                        if (podcast != null) DBProvider.db.savePodcast(podcast);
                        Navigator.pushReplacementNamed(context, PodcastPage.routeName,
                            arguments: PodcastPageArguments(args.podcastId));
                      }
                    },
                    child: Icon(Icons.refresh, size: 26),
                  ))
            ],
            body: data != null
                ? EpisodeList(podcast: data)
                : snapshot.connectionState == ConnectionState.done
                    ? Text("Unable to load podcast from database.")
                    : Center(child: CircularProgressIndicator()),
          );
        });
  }
}

class EpisodeList extends StatelessWidget {
  final Podcast podcast;

  EpisodeList({Key? key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: podcast.episodes.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) return EpisodeListHeader(podcast: podcast);
        return EpisodeListItem(episode: podcast.episodes[index - 1]);
      },
    );
  }
}

class EpisodeListHeader extends StatelessWidget {
  final Podcast podcast;

  EpisodeListHeader({Key? key, required this.podcast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = podcast.imageUrl;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: imageUrl != null
                ? Image(image: CachedNetworkImageProvider(imageUrl), fit: BoxFit.cover)
                : Container(),
          )),
      Expanded(
          flex: 2,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(children: [
                Text(podcast.title, style: Theme.of(context).textTheme.headline2),
                SubscribeButton(podcast)
              ]))),
    ]);
  }
}

class SubscribeButton extends StatelessWidget {
  final Podcast podcast;

  SubscribeButton(this.podcast);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionsCubit, List<Podcast>>(builder: (context, snapshot) {
      return ElevatedButton(
        child: Text(snapshot.any((p) => p.rssUrl == podcast.rssUrl) ? "UNSUBSCRIBE" : "SUBSCRIBE"),
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            textStyle: TextStyle(color: Theme.of(context).textTheme.headline1?.color)),
        onPressed: () {
          context.read<SubscriptionsCubit>().toggleSubscription(podcast);
        },
      );
    });
  }
}

class EpisodeListItem extends StatelessWidget {
  final Episode episode;

  EpisodeListItem({Key? key, required this.episode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, List<PlaylistEntry>>(builder: (context, snapshot) {
      return ListTile(
        title: Text(episode.title),
        subtitle: Text(DateTime.now().difference(episode.pubDate).inDays.toString() + " days old"),
        trailing: snapshot.any((element) => element.episode.id == episode.id)
            ? IconButton(
                icon: Icon(Icons.playlist_remove),
                color: Colors.red,
                onPressed: () => context.read<PlaylistCubit>().removeFromPlaylist(episode.id))
            : IconButton(
                icon: Icon(Icons.playlist_add),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () => context.read<PlaylistCubit>().addEpisodeToPlaylist(episode.id)),
      );
    });
  }
}
