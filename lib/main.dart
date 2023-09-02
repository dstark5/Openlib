import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:openlib/ui/themes.dart';
import 'package:openlib/ui/trending_page.dart';
import 'package:openlib/ui/search_page.dart';
import 'package:openlib/ui/mylibrary_page.dart';
import 'package:openlib/ui/settings_page.dart';
import 'package:openlib/services/database.dart' show Sqlite, MyLibraryDb;
import 'package:openlib/services/files.dart'
    show moveFilesToAndroidInternalStorage;
import 'package:openlib/state/state.dart'
    show
        selectedIndexProvider,
        themeModeProvider,
        openPdfWithExternalAppProvider,
        openEpubWithExternalAppProvider,
        dbProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Database initDb = await Sqlite.initDb();
  MyLibraryDb dataBase = MyLibraryDb(dbInstance: initDb);
  bool isDarkMode = await dataBase.getPreference('darkMode');
  bool openPdfwithExternalapp =
      await dataBase.getPreference('openPdfwithExternalApp');
  bool openEpubwithExternalapp =
      await dataBase.getPreference('openEpubwithExternalApp');

  if (Platform.isAndroid) {
    await moveFilesToAndroidInternalStorage();
  }

  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(dataBase),
        themeModeProvider.overrideWith(
            (ref) => isDarkMode ? ThemeMode.dark : ThemeMode.light),
        openPdfWithExternalAppProvider
            .overrideWith((ref) => openPdfwithExternalapp),
        openEpubWithExternalAppProvider
            .overrideWith((ref) => openEpubwithExternalapp)
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ref.watch(themeModeProvider),
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
    MyLibraryPage(),
    SettingsPage()
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
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 125),
          gap: 5,
          color: const Color.fromARGB(255, 255, 255, 255),
          activeColor: const Color.fromARGB(255, 255, 255, 255),
          iconSize: 19, // tab button icon size
          tabBackgroundColor: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6.5),
          tabs: const [
            GButton(
              icon: Icons.trending_up,
              text: 'Trending',
              iconColor: Colors.white,
              textStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 11,
              ),
            ),
            GButton(
              icon: Icons.search,
              text: 'Search',
              iconColor: Colors.white,
              textStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 11,
              ),
            ),
            GButton(
              icon: Icons.collections_bookmark,
              text: 'My Library',
              iconColor: Colors.white,
              textStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 11,
              ),
            ),
            GButton(
              icon: Icons.build,
              text: 'Settings',
              iconColor: Colors.white,
              textStyle: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 11,
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
