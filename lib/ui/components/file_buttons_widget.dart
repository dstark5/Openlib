import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openlib/ui/components/delete_dialog_widget.dart';
import 'package:openlib/ui/epub_viewer.dart' show launchEpubViewer;
import 'package:openlib/ui/pdf_viewer.dart' show launchPdfViewer;

class FileOpenAndDeleteButtons extends ConsumerWidget {
  final String id;
  final String format;
  final Function onDelete;

  const FileOpenAndDeleteButtons(
      {Key? key,
      required this.id,
      required this.format,
      required this.onDelete})
      : super(key: key);

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
              } else {
                await launchEpubViewer(
                    fileName: '$id.$format', context: context, ref: ref);
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
