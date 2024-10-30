// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:openlib/services/database.dart';
import 'package:openlib/services/share_book.dart';
import 'package:openlib/ui/components/book_info_widget.dart';
import 'package:openlib/ui/components/file_buttons_widget.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    MyLibraryDb dataBase = MyLibraryDb.instance;
    final bookInfo = dataBase.getId(id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Openlib"),
        titleTextStyle: Theme.of(context).textTheme.displayLarge,
        actions: [
          FutureBuilder(
              future: bookInfo,
              builder: (BuildContext context, AsyncSnapshot<MyBook?> snapshot) {
                if (snapshot.hasData &&
                    snapshot.data?.title != null &&
                    snapshot.data?.link != null) {
                  return IconButton(
                    icon: Icon(
                      Icons.share_sharp,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    iconSize: 19.0,
                    onPressed: () async {
                      await shareBook(snapshot.data!.title, snapshot.data!.link,
                          snapshot.data?.thumbnail ?? '');
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              })
        ],
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) {
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
