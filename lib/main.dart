import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:podax_flutter/ui/ListenPodcastDetail.dart';

import 'model/PlaylistCubit.dart';
import 'model/SubscriptionsCubit.dart';
import 'ui/Chrome.dart';
import 'ui/ListenGenreGrid.dart';
import 'ui/ListenToplistPage.dart';
import 'ui/PlaylistList.dart';
import 'ui/PodcastPage.dart';
import 'ui/SubscriptionList.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<PlaylistCubit>(create: (context) => PlaylistCubit([])),
          BlocProvider<SubscriptionsCubit>(create: (context) => SubscriptionsCubit([])),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Podax",
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(primary: Color(0xFFE0BA63), secondary: Color(0XFF3EC2D3)),
          ),
          theme: ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(primary: Color(0xFFE0BA63), secondary: Color(0XFF3EC2D3))),
          themeMode: ThemeMode.system,
          initialRoute: "/",
          routes: {
            "/": (context) => HomePage(),
            ListenToplistPage.routeName: (context) => ListenToplistPage(),
            ListenPodcastPage.routeName: (context) => ListenPodcastPage(),
            PodcastPage.routeName: (context) => PodcastPage(),
          },
        ));
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController = PageController();

  int _selectedPage = 0;
  void changePage(int page) {
    _pageController.jumpToPage(page);
    setState(() {
      _selectedPage = page;
    });
  }

  FloatingActionButton _fab = FloatingActionButton(
    onPressed: () {},
    tooltip: 'Increment',
    child: Icon(Icons.add),
  );

  @override
  Widget build(BuildContext context) {
    return Chrome(
      bottomNavigationBar: Container(
          color: Theme.of(context).primaryColor,
          child: BottomNavigationBar(items: [
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Toplists"),
            BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Subscriptions"),
            BottomNavigationBarItem(icon: Icon(Icons.view_list), label: "Playlist")
          ], currentIndex: _selectedPage, onTap: changePage)),
      body: PageView(
          controller: _pageController,
          children: [ListenGenreGrid(), SubscriptionList(), PlaylistList()]),
      floatingActionButton: _selectedPage != 0 ? _fab : null,
    );
  }
}
