import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'PlayerRow.dart';

class Chrome extends StatefulWidget {
  final String? title;
  final Widget? bottomNavigationBar;
  final Widget? body;
  final Widget? floatingActionButton;

  Chrome({this.title, this.bottomNavigationBar, this.body, this.floatingActionButton});

  @override
  _ChromeState createState() => _ChromeState();
}

class _ChromeState extends State<Chrome> {
  PlayerRow _playerRow = PlayerRow();

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      body: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
          child: Scaffold(
            appBar: AppBar(title: Text(widget.title ?? "Podax")),
            bottomNavigationBar: widget.bottomNavigationBar,
            body: widget.body,
            floatingActionButton: widget.floatingActionButton,
          )),
      collapsed: _playerRow,
      panel: Material(),
      minHeight: 50,
      maxHeight: MediaQuery.of(context).size.height,
      backdropEnabled: true,
    );
  }
}
