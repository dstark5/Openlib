// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/services/files.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:openlib/services/database.dart';
import 'package:openlib/ui/about_page.dart';
import 'package:openlib/ui/components/page_title_widget.dart';

import 'package:openlib/state/state.dart'
    show themeModeProvider, openPdfWithExternalAppProvider;

Future<void> requestStoragePermission() async {
  bool permissionGranted = false;
  // Check whether the device is running Android 11 or higher
  DeviceInfoPlugin plugin = DeviceInfoPlugin();
  AndroidDeviceInfo android = await plugin.androidInfo;
  // Android < 11
  if (android.version.sdkInt < 33) {
    if (await Permission.storage.request().isGranted) {
      permissionGranted = true;
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    }
  }
  // Android > 11
  else {
    if (await Permission.manageExternalStorage.request().isGranted) {
      permissionGranted = true;
    } else if (await Permission.manageExternalStorage
        .request()
        .isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.manageExternalStorage.request().isDenied) {
      permissionGranted = false;
    }
  }
  print("Storage permission status: $permissionGranted");
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MyLibraryDb dataBase = MyLibraryDb.instance;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitleText("Settings"),
            _PaddedContainer(
              children: [
                Text(
                  "Dark Mode",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                Switch(
                  // This bool value toggles the switch.
                  value: ref.watch(themeModeProvider) == ThemeMode.dark,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    ref.read(themeModeProvider.notifier).state =
                        value == true ? ThemeMode.dark : ThemeMode.light;
                    dataBase.savePreference('darkMode', value);
                    if (Platform.isAndroid) {
                      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                          systemNavigationBarColor:
                              value ? Colors.black : Colors.grey.shade200));
                    }
                  },
                )
              ],
            ),
            _PaddedContainer(
              children: [
                Text(
                  "Open PDF with External Reader",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                Switch(
                  // This bool value toggles the switch.
                  value: ref.watch(openPdfWithExternalAppProvider),
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    ref.read(openPdfWithExternalAppProvider.notifier).state =
                        value;
                    dataBase.savePreference('openPdfwithExternalApp', value);
                  },
                )
              ],
            ),
            _PaddedContainer(
                onClick: () async {
                  final currentDirectory =
                      await dataBase.getPreference('bookStorageDirectory');
                  String? pickedDirectory =
                      await FilePicker.platform.getDirectoryPath();
                  if (pickedDirectory == null) {
                    return;
                  }
                  await requestStoragePermission();
                  // Attempt moving existing books to the new directory
                  moveFolderContents(currentDirectory, pickedDirectory);
                  dataBase.savePreference(
                      'bookStorageDirectory', pickedDirectory);
                },
                children: [
                  Text(
                    "Change storage path",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Icon(Icons.folder),
                ]),
            _PaddedContainer(
              onClick: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return const AboutPage();
                }));
              },
              children: [
                Text(
                  "About",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _PaddedContainer extends StatelessWidget {
  const _PaddedContainer({this.onClick, required this.children});

  final VoidCallback? onClick;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
      child: InkWell(
        onTap: onClick,
        child: Container(
          height: 61,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
