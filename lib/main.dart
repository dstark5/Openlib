// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:openlib/ui/home_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Project imports:
import 'package:openlib/services/database.dart' show MyLibraryDb;
import 'package:openlib/ui/mylibrary_page.dart';
import 'package:openlib/ui/search_page.dart';
import 'package:openlib/ui/settings_page.dart';
import 'package:openlib/ui/themes.dart';

import 'package:openlib/services/files.dart'
    show moveFilesToAndroidInternalStorage;
import 'package:openlib/state/state.dart'
    show
        selectedIndexProvider,
        themeModeProvider,
        openPdfWithExternalAppProvider,
        openEpubWithExternalAppProvider,
        userAgentProvider,
        cookieProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  MyLibraryDb dataBase = MyLibraryDb.instance;
  bool isDarkMode =
      await dataBase.getPreference('darkMode') == 0 ? false : true;

  bool openPdfwithExternalapp =
      await dataBase.getPreference('openPdfwithExternalApp') == 0
          ? false
          : true;

  bool openEpubwithExternalapp =
      await dataBase.getPreference('openEpubwithExternalApp') == 0
          ? false
          : true;

  String browserUserAgent = await dataBase.getBrowserOptions('userAgent');
  String browserCookie = await dataBase.getBrowserOptions('cookie');

  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor:
            isDarkMode ? Colors.black : Colors.grey.shade200));
    await moveFilesToAndroidInternalStorage();
  }

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(
            (ref) => isDarkMode ? ThemeMode.dark : ThemeMode.light),
        openPdfWithExternalAppProvider
            .overrideWith((ref) => openPdfwithExternalapp),
        openEpubWithExternalAppProvider
            .overrideWith((ref) => openEpubwithExternalapp),
        userAgentProvider.overrideWith((ref) => browserUserAgent),
        cookieProvider.overrideWith((ref) => browserCookie),
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'Openlib',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ref.watch(themeModeProvider),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    MyLibraryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              expandedHeight: 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.only(left: 16, bottom: 12),
                title: Text(
                  "Openlib",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
          ];
        },
        body: _widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: SafeArea(
        child: GNav(
          backgroundColor:
              isDarkMode ? Colors.black : Colors.grey.shade200,
          haptic: true,
          tabBorderRadius: 50,
          tabActiveBorder: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
          tabMargin: const EdgeInsets.fromLTRB(13, 6, 13, 2.5),
          curve: Curves.fastLinearToSlowEaseIn,
          duration: const Duration(milliseconds: 25),
          gap: 5,
          color: Colors.white,
          activeColor: Colors.white,
          iconSize: 19,
          tabBackgroundColor:
              Theme.of(context).colorScheme.secondary,
          padding:
              const EdgeInsets.symmetric(horizontal: 13, vertical: 6.5),
          tabs: const [
            GButton(icon: Icons.trending_up, text: 'Home'),
            GButton(icon: Icons.search, text: 'Search'),
            GButton(icon: Icons.collections_bookmark, text: 'My Library'),
            GButton(icon: Icons.build, text: 'Settings'),
          ],
          selectedIndex: selectedIndex,
          onTabChange: (index) {
            ref.read(selectedIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }
}
