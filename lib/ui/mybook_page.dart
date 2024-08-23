// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/services/database.dart';
import 'package:openlib/ui/components/book_info_widget.dart';
import 'package:openlib/ui/components/file_buttons_widget.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Openlib"),
        titleTextStyle: Theme.of(context).textTheme.displayLarge,
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) {
          MyLibraryDb dataBase = MyLibraryDb.instance;

          final bookInfo = dataBase.getId(id);

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
                      child: SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ));
                }
              });
        },
      ),
    );
  }
}
