import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/state/state.dart' show dbProvider;

import 'package:openlib/ui/components/book_info_widget.dart';
import 'package:openlib/ui/components/file_buttons_widget.dart';

class BookPage extends StatelessWidget {
  const BookPage({Key? key, required this.id, required this.title})
      : super(key: key);

  final String id;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        titleSpacing: 0,
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) {
          final bookInfo = ref.read(dbProvider).getId(id);

          return FutureBuilder(
              future: bookInfo,
              builder: (BuildContext context, AsyncSnapshot<MyBook?> snapshot) {
                if (snapshot.hasData) {
                  return BookInfoWidget(
                      data: snapshot.data,
                      child: FileOpenAndDeleteButtons(
                        id: snapshot.data!.id,
                        format: snapshot.data!.format!,
                        onDelete: () {
                          Navigator.of(context).pop();
                        },
                      ));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.toString()),
                  );
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  ));
                }
              });
        },
      ),
    );
  }
}
