import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:open_file/open_file.dart';

import 'package:openlib/services/files.dart' show getFilePath;
import 'package:openlib/ui/components/snack_bar_widget.dart';
import 'package:openlib/state/state.dart'
    show
        filePathProvider,
        saveEpubState,
        dbProvider,
        getBookPosition,
        openEpubWithExternalAppProvider;

Future<void> launchEpubViewer(
    {required String fileName,
    required BuildContext context,
    required WidgetRef ref}) async {
  if (Platform.isAndroid || Platform.isIOS) {
    String path = await getFilePath(fileName);
    String? epubConfig = await ref.read(dbProvider).getBookState(fileName);
    bool openWithExternalApp = ref.watch(openEpubWithExternalAppProvider);

    if (openWithExternalApp) {
      await OpenFile.open(path);
    } else {
      try {
        VocsyEpub.setConfig(
          // ignore: use_build_context_synchronously
          themeColor: const Color.fromARGB(255, 210, 15, 1),
          identifier: "iosBook",
          scrollDirection: EpubScrollDirection.HORIZONTAL,
        );

        if ((epubConfig?.isNotEmpty ?? true) &&
            (epubConfig != null) &&
            (!(epubConfig.startsWith('epubcfi')))) {
          VocsyEpub.open(path,
              lastLocation: EpubLocator.fromJson(json.decode(epubConfig)));
        } else {
          VocsyEpub.open(path);
        }

        VocsyEpub.locatorStream.listen((locator) async {
          await saveEpubState(fileName, locator, ref);
          // convert locator from string to json and save to your database to be retrieved later
        });
      } catch (e) {
        // ignore: use_build_context_synchronously
        showSnackBar(context: context, message: 'Unable to open pdf!');
      }
    }
  } else {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return EpubViewerWidget(
        fileName: fileName,
      );
    }));
  }
}

class EpubViewerWidget extends ConsumerStatefulWidget {
  const EpubViewerWidget({super.key, required this.fileName});

  final String fileName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EpubViewState();
}

class _EpubViewState extends ConsumerState<EpubViewerWidget> {
  @override
  Widget build(BuildContext context) {
    final filePath = ref.watch(filePathProvider(widget.fileName));
    return filePath.when(data: (data) {
      return EpubViewer(filePath: data, fileName: widget.fileName);
    }, error: (error, stack) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Openlib"),
          titleTextStyle: Theme.of(context).textTheme.displayLarge,
        ),
        body: Center(child: Text(error.toString())),
      );
    }, loading: () {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Openlib"),
          titleTextStyle: Theme.of(context).textTheme.displayLarge,
        ),
        body: Center(
          child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      );
    });
  }
}

class EpubViewer extends ConsumerStatefulWidget {
  const EpubViewer({super.key, required this.filePath, required this.fileName});

  final String filePath;
  final String fileName;

  @override
  // ignore: library_private_types_in_public_api
  _EpubViewerState createState() => _EpubViewerState();
}

class _EpubViewerState extends ConsumerState<EpubViewer> {
  late EpubController _epubReaderController;
  String? epubConf;

  @override
  void initState() {
    _epubReaderController = EpubController(
      document: EpubDocument.openFile(File(widget.filePath)),
    );
    super.initState();
  }

  @override
  void deactivate() {
    if (Platform.isAndroid || Platform.isIOS) {
      saveEpubState(widget.fileName, epubConf, ref);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _epubReaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(getBookPosition(widget.fileName));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Openlib"),
        titleTextStyle: Theme.of(context).textTheme.displayLarge,
      ),
      endDrawer: Drawer(
        child: EpubViewTableOfContents(controller: _epubReaderController),
      ),
      body: position.when(
        data: (data) {
          return EpubView(
            onDocumentLoaded: (doc) {
              Future.delayed(const Duration(milliseconds: 20), () {
                String pos = data ?? "";
                _epubReaderController.gotoEpubCfi(pos);
              });
            },
            onChapterChanged: (value) {
              epubConf = _epubReaderController.generateEpubCfi();
            },
            builders: EpubViewBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              chapterDividerBuilder: (_) => const Divider(),
            ),
            controller: _epubReaderController,
          );
        },
        error: (err, _) {
          return EpubView(
            onChapterChanged: (value) {
              epubConf = _epubReaderController.generateEpubCfi();
            },
            builders: EpubViewBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              chapterDividerBuilder: (_) => const Divider(),
            ),
            controller: _epubReaderController,
          );
        },
        loading: () {
          return Center(
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          );
        },
      ),
    );
  }
}
