import 'dart:async';

import 'package:bloc/bloc.dart';

import 'Podcast.dart';
import 'db.dart';

class SubscriptionsCubit extends Cubit<List<Podcast>> {
  SubscriptionsCubit(List<Podcast> initialState) : super(initialState) {
    reload();
  }

  Future reload() async {
    emit(await DBProvider.db.getPodcastsFromRssUrl(await DBProvider.db.getSubscriptions()));
  }

  Future addSubscription(Podcast podcast) async {
    await DBProvider.db.addSubscription(podcast);
    reload();
  }

  Future removeSubscription(Podcast podcast) async {
    await DBProvider.db.removeSubscription(podcast);
    reload();
  }

  Future<bool> isSubscribed(Podcast podcast) async {
    final rssUrls = await DBProvider.db.getSubscriptions();
    return rssUrls.contains(podcast.rssUrl);
  }

  Future toggleSubscription(Podcast podcast) async {
    if (await DBProvider.db.isSubscribed(podcast))
      removeSubscription(podcast);
    else
      addSubscription(podcast);
  }
}
