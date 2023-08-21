import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/ui/components/snack_bar_widget.dart';
import 'package:openlib/state/state.dart' show FileName, deleteFileFromMyLib;

class ShowDeleteDialog extends ConsumerWidget {
  final String id;
  final String format;
  final Function onDelete;

  const ShowDeleteDialog(
      {super.key,
      required this.id,
      required this.format,
      required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // if (false) {
    //   return
    // }

    return AlertDialog(
      title: const Text("Delete Book?"),
      content: const Text("This is permanent and cannot be undone"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            ref.read(deleteFileFromMyLib(FileName(md5: id, format: format)));
            Navigator.of(context).pop();

            showSnackBar(context: context, message: 'Book has been Deleted!');

            onDelete();
          },
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
