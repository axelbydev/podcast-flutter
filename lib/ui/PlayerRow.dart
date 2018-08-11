import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podax_flutter/model/db.dart';

import '../model/Episode.dart';
import '../model/PlaylistCubit.dart';
import '../model/PlaylistEntry.dart';

class PlayerRow extends StatefulWidget {
  @override
  _PlayerRowState createState() => _PlayerRowState();
}

class _PlayerRowState extends State<PlayerRow> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration? lastUpdate;
  Episode? playingEpisode;

  _PlayerRowState() {
    audioPlayer.onPositionChanged.listen((event) {
      final ep = playingEpisode;
      final lastSeconds = lastUpdate?.inSeconds;
      if (ep != null) {
        ep.lastPosition = event.inMilliseconds / 1000.0;
        if (lastSeconds != null && lastSeconds != event.inSeconds) {
          DBProvider.db.updateLastPlayed(ep, event.inMilliseconds / 1000.0);
        }
      }
      lastUpdate = event;
    });
    audioPlayer.onPlayerComplete.listen((event) async {
      final ep = playingEpisode;
      if (ep == null) return;
      await DBProvider.db.completeEpisode(ep);
      final playlist = await DBProvider.db.getPlaylist();
      if (playlist.length > 0) {
        audioPlayer.play(UrlSource(playlist[0].episode.enclosure));
        audioPlayer.seek(Duration(milliseconds: (playlist[0].episode.lastPosition * 1000).floor()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<PlaylistCubit, List<PlaylistEntry>>(builder: (context, snapshot) {
      return Material(
          color: theme.primaryColor,
          child: Row(children: [
            IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Theme.of(context).colorScheme.secondary),
                onPressed: () {
                  if (snapshot.length == 0) return;
                  if (isPlaying) {
                    audioPlayer.pause();
                  } else {
                    playingEpisode = snapshot[0].episode;
                    audioPlayer.play(UrlSource(snapshot[0].episode.enclosure));
                    audioPlayer.seek(
                        Duration(milliseconds: (snapshot[0].episode.lastPosition * 1000).floor()));
                  }
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                }),
            Expanded(
                child: Text(
                    snapshot.length > 0 ? snapshot.elementAt(0).episode.title : "playlist is empty",
                    style: theme.primaryTextTheme.bodyText1)),
          ]));
    });
  }
}
