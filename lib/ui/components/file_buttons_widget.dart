// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';

// Project imports:
import 'package:openlib/services/files.dart' show getFilePath;
import 'package:openlib/ui/components/delete_dialog_widget.dart';
import 'package:openlib/ui/components/snack_bar_widget.dart';
import 'package:openlib/ui/epub_viewer.dart' show launchEpubViewer;
import 'package:openlib/ui/pdf_viewer.dart' show launchPdfViewer;

class FileOpenAndDeleteButtons extends ConsumerWidget {
  final String id;
  final String format;
  final Function onDelete;

  const FileOpenAndDeleteButtons(
      {super.key,
      required this.id,
      required this.format,
      required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 21, bottom: 21),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                )),
            onPressed: () async {
              if (format == 'pdf') {
                await launchPdfViewer(
                    fileName: '$id.$format', context: context, ref: ref);
              } else if (format == 'epub') {
                await launchEpubViewer(
                    fileName: '$id.$format', context: context, ref: ref);
              } else {
                await openCbrAndCbz(fileName: '$id.$format', context: context);
              }
            },
            child: const Padding(
              padding: EdgeInsets.fromLTRB(17, 8, 17, 8),
              child: Text('Open'),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  side: BorderSide(
                      width: 3, color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return ShowDeleteDialog(
                      id: id,
                      format: format,
                      onDelete: onDelete,
                    );
                  });
            },
            child: Padding(
              padding: const EdgeInsets.all(5.3),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> openCbrAndCbz(
    {required String fileName, required BuildContext context}) async {
  try {
    String path = await getFilePath(fileName);
    await OpenFile.open(path);
  } catch (e) {
    // ignore: avoid_print
    // print(e);
    // ignore: use_build_context_synchronously
    showSnackBar(context: context, message: 'Unable to open pdf!');
  }
}
