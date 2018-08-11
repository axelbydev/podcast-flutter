import 'package:flutter/material.dart';

import '../services/ListenAPI.dart';
import 'ListenToplistPage.dart';

class ListenGenreGrid extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder<List<ListenAPIGenre>>(
        initialData: [],
        future: fetchListenGenres(),
        builder: (context, snapshot) => GridView.extent(
            maxCrossAxisExtent: 200,
            children: (snapshot.data ?? [])
                .map((g) => Padding(
                    padding: EdgeInsets.all(10),
                    child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, ListenToplistPage.routeName,
                              arguments: ListenToplistArguments(g));
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Theme.of(context).colorScheme.secondary)),
                            child: Center(
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      g.name,
                                      style: Theme.of(context).textTheme.headline6,
                                      textAlign: TextAlign.center,
                                    )))))))
                .toList(growable: false)));
  }
}
