import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openlib/ui/components/delete_dialog_widget.dart';
import 'package:openlib/ui/epub_viewer.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:openlib/ui/pdf_viewer.dart';
import 'package:openlib/services/files.dart';
import 'package:openlib/state/state.dart' show saveEpubState, dbProvider;

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
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return PdfView(
                    fileName: '$id.$format',
                  );
                }));
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

Future<void> launchEpubViewer(
    {required String fileName,
    required BuildContext context,
    required WidgetRef ref}) async {
  if (Platform.isAndroid || Platform.isIOS) {
    String path = await getFilePath(fileName);
    String? epubConfig = await ref.read(dbProvider).getBookState(fileName);

    VocsyEpub.setConfig(
      // ignore: use_build_context_synchronously
      themeColor: Theme.of(context).colorScheme.secondary,
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

    VocsyEpub.locatorStream.listen((locator) {
      saveEpubState(fileName, locator, ref);
      // convert locator from string to json and save to your database to be retrieved later
    });
  } else {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return EpubViewerWidget(
        fileName: fileName,
      );
    }));
  }
}
