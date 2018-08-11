import 'package:bloc/bloc.dart';
import 'package:podax_flutter/model/PlaylistEntry.dart';

import 'db.dart';

class PlaylistCubit extends Cubit<List<PlaylistEntry>> {
  PlaylistCubit(List<PlaylistEntry> initialState) : super(initialState) {
    reload();
  }

  Future reload() async {
    emit(await DBProvider.db.getPlaylist());
  }

  Future addEpisodeToPlaylist(int episodeId, {bool insertAtFront = false}) async {
    if (insertAtFront)
      await DBProvider.db.insertIntoPlaylist(episodeId);
    else
      await DBProvider.db.addToPlaylist(episodeId);
    reload();
  }

  Future removeFromPlaylist(int episodeId) async {
    await DBProvider.db.removeFromPlaylist(episodeId);
    reload();
  }
}
