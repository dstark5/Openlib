import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openlib/state/state.dart'
    show filePathProvider, saveEpubState, getBookPosition;

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
          // backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Openlib"),
          // titleTextStyle: Theme.of(context).textTheme.displayLarge,
        ),
        body: Center(child: Text(error.toString())),
      );
    }, loading: () {
      return Scaffold(
        appBar: AppBar(
          // backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text("Openlib"),
          // titleTextStyle: Theme.of(context).textTheme.displayLarge,
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
  const EpubViewer({Key? key, required this.filePath, required this.fileName})
      : super(key: key);

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
        // backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Openlib"),
        titleSpacing: 0,
        // titleTextStyle: Theme.of(context).textTheme.displayLarge,
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
