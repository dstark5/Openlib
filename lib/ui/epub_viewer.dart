// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:epub_view/epub_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/ui/components/snack_bar_widget.dart';
import 'package:openlib/state/state.dart'
    show
        filePathProvider,
        saveEpubState,
        getBookPosition,
        readerPreferenceProvider,
        readerAppsProvider;

Future<void> launchEpubViewer({
  required String fileName,
  required BuildContext context,
  required WidgetRef ref,
  String? title,
}) async {
  final reader = ref.read(readerPreferenceProvider('epub'));
  if (reader != 'internal') {
    try {
      final path = await ref.read(filePathProvider(fileName).future);
      await ref
          .read(readerAppsProvider)
          .openBook(path: path, format: 'epub', reader: reader, title: title);
    } catch (_) {
      if (context.mounted) {
        showSnackBar(
            context: context,
            message:
                'Could not open the reader. Choose another app in Settings.');
      }
    }
    return;
  }
  if (!context.mounted) return;
  Navigator.push(context,
      MaterialPageRoute(builder: (_) => EpubViewerWidget(fileName: fileName)));
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
    return filePath.when(
      data: (data) {
        return EpubViewer(filePath: data, fileName: widget.fileName);
      },
      error: (error, stack) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text("Openlib"),
            titleTextStyle: Theme.of(context).textTheme.displayLarge,
          ),
          body: Center(child: Text(error.toString())),
        );
      },
      loading: () {
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
      },
    );
  }
}

class EpubViewer extends ConsumerStatefulWidget {
  const EpubViewer({super.key, required this.filePath, required this.fileName});

  final String filePath;
  final String fileName;

  @override
  _EpubViewerState createState() => _EpubViewerState();
}

class _EpubViewerState extends ConsumerState<EpubViewer> {
  late EpubController _epubReaderController;
  String? epubConf;

  @override
  void initState() {
    super.initState();
    _epubReaderController = EpubController(
      document: EpubDocument.openFile(File(widget.filePath)),
    );
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
                if (data != null && data.isNotEmpty) {
                  _epubReaderController.gotoEpubCfi(data);
                }
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
