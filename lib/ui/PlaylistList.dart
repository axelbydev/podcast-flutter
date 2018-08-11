import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podax_flutter/model/PlaylistCubit.dart';

import '../model/PlaylistEntry.dart';

class PlaylistList extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistCubit, List<PlaylistEntry>>(builder: (context, snapshot) {
      return ListView.builder(
        itemCount: snapshot.length,
        itemBuilder: ((context, index) => ListTile(
              title: Text("${index + 1}: ${snapshot[index].episode.title}"),
              trailing: IconButton(
                  icon: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.secondary),
                  onPressed: () {}),
            )),
      );
    });
  }
}
