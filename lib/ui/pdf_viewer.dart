// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:openlib/ui/components/snack_bar_widget.dart';

// Project imports:

import 'package:openlib/state/state.dart'
    show
        filePathProvider,
        pdfCurrentPage,
        totalPdfPage,
        savePdfState,
        readerPreferenceProvider,
        readerAppsProvider,
        getBookPosition;

Future<void> launchPdfViewer({
  required String fileName,
  required BuildContext context,
  required WidgetRef ref,
  String? title,
}) async {
  final reader = ref.read(readerPreferenceProvider('pdf'));
  if (reader != 'internal') {
    try {
      final path = await ref.read(filePathProvider(fileName).future);
      await ref
          .read(readerAppsProvider)
          .openBook(path: path, format: 'pdf', reader: reader, title: title);
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
  Navigator.push(
      context, MaterialPageRoute(builder: (_) => PdfView(fileName: fileName)));
}

class PdfView extends ConsumerStatefulWidget {
  const PdfView({super.key, required this.fileName});

  final String fileName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PdfViewState();
}

class _PdfViewState extends ConsumerState<PdfView> {
  @override
  Widget build(BuildContext context) {
    final filePath = ref.watch(filePathProvider(widget.fileName));
    return filePath.when(data: (data) {
      return PdfViewer(filePath: data, fileName: widget.fileName);
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
        )),
      );
    });
  }
}

class PdfViewer extends ConsumerStatefulWidget {
  const PdfViewer({super.key, required this.filePath, required this.fileName});

  final String filePath;
  final String fileName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PdfViewerState();
}

class _PdfViewerState extends ConsumerState<PdfViewer> {
  late PDFViewController controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    if (Platform.isAndroid || Platform.isIOS) {
      savePdfState(widget.fileName, ref);
    }
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openPdfWithDefaultViewer(String fileName) async {
    debugPrint("Opening : $fileName");
    final fileUrl = Uri.parse(fileName);
    if (await canLaunchUrl(fileUrl)) {
      await launchUrl(fileUrl);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'Could not open the PDF',
          textAlign: TextAlign.center,
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Platform.isAndroid || Platform.isIOS;
    final currentPage = ref.watch(pdfCurrentPage);
    final totalPages = ref.watch(totalPdfPage);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Openlib"),
        titleTextStyle: Theme.of(context).textTheme.displayLarge,
        actions: isMobile
            ? [
                IconButton(
                    onPressed: () {
                      if (currentPage != 0) {
                        ref.read(pdfCurrentPage.notifier).state =
                            currentPage - 1;
                        controller.setPage(currentPage - 1);
                      } else {
                        ref.read(pdfCurrentPage.notifier).state = totalPages;
                        controller.setPage(totalPages - 1);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_left,
                      size: 25,
                    )),
                Text(
                    '${(currentPage + 1).toString()} / ${totalPages.toString()}'),
                IconButton(
                    onPressed: () {
                      if (currentPage + 1 < totalPages) {
                        ref.read(pdfCurrentPage.notifier).state =
                            currentPage + 1;
                        controller.setPage(currentPage + 1);
                      } else {
                        ref.read(pdfCurrentPage.notifier).state = 0;
                        controller.setPage(0);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_right,
                      size: 25,
                    )),
              ]
            : [],
      ),
      body: isMobile
          ? ref.watch(getBookPosition(widget.fileName)).when(
              data: (data) {
                return PDFView(
                  swipeHorizontal: true,
                  fitEachPage: true,
                  fitPolicy: FitPolicy.BOTH,
                  filePath: widget.filePath,
                  onViewCreated: (controller) {
                    this.controller = controller;
                  },
                  defaultPage: int.parse(data ?? '0'),
                  onPageChanged: (page, total) {
                    ref.read(pdfCurrentPage.notifier).state = page ?? 0;
                    ref.read(totalPdfPage.notifier).state = total ?? 0;
                  },
                );
              },
              error: (error, stackTrace) {
                return PDFView(
                  swipeHorizontal: true,
                  fitEachPage: true,
                  fitPolicy: FitPolicy.BOTH,
                  filePath: widget.filePath,
                  onViewCreated: (controller) {
                    this.controller = controller;
                  },
                  onPageChanged: (page, total) {
                    ref.read(pdfCurrentPage.notifier).state = page ?? 0;
                    ref.read(totalPdfPage.notifier).state = total ?? 0;
                  },
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
                ));
              },
            )
          : Center(
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    )),
                onPressed: () async {
                  await _openPdfWithDefaultViewer("file://${widget.filePath}");
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Open with System's PDF Viewer",
                  ),
                ),
              ),
            ),
    );
  }
}
