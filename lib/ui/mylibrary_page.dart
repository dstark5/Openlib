import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:openlib/ui/extensions.dart';
import 'package:openlib/ui/mybook_page.dart';
import 'package:openlib/ui/components/error_widget.dart';
import 'package:openlib/ui/components/page_title_widget.dart';
import 'package:openlib/ui/components/book_card_widget.dart';
import 'package:openlib/state/state.dart' show myLibraryProvider;

class MyLibraryPage extends ConsumerWidget {
  const MyLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myBooks = ref.watch(myLibraryProvider);
    return myBooks.when(
      data: (data) {
        if (data.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
            child: CustomScrollView(
              slivers: <Widget>[
                const SliverToBoxAdapter(
                  child: TitleText("My Library"),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(data
                        .map((i) => BookInfoCard(
                            title: i.title,
                            author: i.author ?? "",
                            publisher: i.publisher ?? "",
                            thumbnail: i.thumbnail,
                            link: i.link,
                            onClick: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return BookPage(id: i.id, title: i.title);
                              }));
                            }))
                        .toList()),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 200,
                child: SvgPicture.asset(
                  'assets/empty_mylib.svg',
                  width: 200,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "My Library Is Empty!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: "#4D4D4D".toColor(),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          );
        }
      },
      error: (error, _) {
        return CustomErrorWidget(error: error, stackTrace: _);
      },
      loading: () {
        return Center(
            child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        ));
      },
    );
  }
}
