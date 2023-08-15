import 'package:flutter/material.dart';
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
    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'Openlib',
      theme: ThemeData(
          primaryColor: Colors.white,
          colorScheme: ColorScheme.light(
            primary: Colors.white,
            secondary: '#FB0101'.toColor(),
            tertiary: Colors.black,
            tertiaryContainer: '#F2F2F2'.toColor(),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
            displayMedium: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          fontFamily: GoogleFonts.nunito().fontFamily,
          useMaterial3: true,
          textSelectionTheme: TextSelectionThemeData(
              selectionColor: '#FB0101'.toColor(),
              selectionHandleColor: '#FB0101'.toColor())),
      home: const HomePage(),
    );
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Openlib"),
        titleTextStyle: Theme.of(context).textTheme.displayLarge,
      ),
      body: _widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: SafeArea(
        child: GNav(
          rippleColor: Colors.redAccent,
          backgroundColor: Colors.black,
          haptic: true,
          tabBorderRadius: 50,
          tabActiveBorder: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
          tabMargin: const EdgeInsets.fromLTRB(13, 6, 13, 2.5),
          curve: Curves.easeInOut, // tab animation curves
          duration: const Duration(milliseconds: 150),
          gap: 5,
          color: const Color.fromARGB(255, 255, 255, 255),
          activeColor: const Color.fromARGB(255, 255, 255, 255),
          iconSize: 21, // tab button icon size
          tabBackgroundColor: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6.5),
          tabs: const [
            GButton(
              icon: Icons.trending_up,
              text: 'Trending',
              iconColor: Colors.white,
              textStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            GButton(
              icon: Icons.search,
              text: 'Search',
              iconColor: Colors.white,
              textStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            GButton(
              icon: Icons.collections_bookmark,
              text: 'My Library',
              iconColor: Colors.white,
              textStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
          selectedIndex: selectedIndex,
          onTabChange: (index) async {
            ref.read(selectedIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }
}
