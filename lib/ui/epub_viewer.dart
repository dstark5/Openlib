import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openlib/state/state.dart' show filePathProvider;

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
        )),
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

  @override
  void initState() {
    _epubReaderController = EpubController(
      document: EpubDocument.openFile(File(widget.filePath)),
    );
    super.initState();
  }

  @override
  void dispose() {
    _epubReaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: EpubView(
        onDocumentLoaded: (doc) {},
        onChapterChanged: (value) {},
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          chapterDividerBuilder: (_) => const Divider(),
        ),
        controller: _epubReaderController,
      ),
    );
  }
}
