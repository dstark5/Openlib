import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:openlib/ui/extensions.dart';
import 'package:openlib/ui/trending_page.dart';
import 'package:openlib/ui/search_page.dart';
import 'package:openlib/ui/mylibrary_page.dart';
import 'package:openlib/services/database.dart' show Sqlite, MyLibraryDb;
import 'package:openlib/state/state.dart'
    show selectedIndexProvider, dbProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Database db = await Sqlite.initDb();
  runApp(
    ProviderScope(
      overrides: [dbProvider.overrideWithValue(MyLibraryDb(dbInstance: db))],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        // builder: (BuildContext context, Widget? child) {
        //   return MediaQuery(
        //     data: MediaQuery.of(context).copyWith(
        //       textScaleFactor: 1.0,
        //     ),
        //     child: child!,
        //   );
        // },
        debugShowCheckedModeBanner: false,
        title: 'Openlib',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkDynamic,
        ),
        home: const HomePage(),
      );
    });
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const List<Widget> _widgetOptions = <Widget>[
    TrendingPage(),
    SearchPage(),
    MyLibraryPage()
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          systemNavigationBarColor: ElevationOverlay.applySurfaceTint(
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceTint,
              3)),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          leading:
              Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
          title: const Text(
            "Openlib",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          titleSpacing: 1,
        ),
        body: _widgetOptions.elementAt(selectedIndex),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.trending_up), label: "Trending"),
            NavigationDestination(icon: Icon(Icons.search), label: "Search"),
            NavigationDestination(
                icon: Icon(Icons.collections_bookmark), label: "My Library"),
          ],
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) async {
            ref.read(selectedIndexProvider.notifier).state = index;
          },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      ),
    );
  }
}
