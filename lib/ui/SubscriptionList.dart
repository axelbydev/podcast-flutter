import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podax_flutter/model/SubscriptionsCubit.dart';

import '../model/Podcast.dart';
import 'PodcastList.dart';
import 'PodcastPage.dart';

class SubscriptionList extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionsCubit, List<Podcast>>(
        builder: (context, snapshot) => PodcastList(
            podcasts: snapshot,
            handleTap: (Podcast podcast) {
              Navigator.pushNamed(context, PodcastPage.routeName,
                  arguments: PodcastPageArguments(podcast.id));
            }));
  }
}
