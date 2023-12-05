import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openlib/ui/extensions.dart';
import 'package:openlib/ui/book_info_page.dart';
import 'package:openlib/ui/components/error_widget.dart';
import 'package:openlib/ui/components/page_title_widget.dart';
import 'package:openlib/ui/components/book_card_widget.dart';
import 'package:openlib/state/state.dart' show searchProvider;

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBooks = ref.watch(searchProvider(searchQuery));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Openlib"),
        titleTextStyle: Theme.of(context).textTheme.displayLarge,
      ),
      body: searchBooks.when(
        data: (data) {
          if (data.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
              child: CustomScrollView(
                slivers: <Widget>[
                  const SliverToBoxAdapter(
                    child: TitleText("Results"),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(data
                          .map((i) => BookInfoCard(
                                title: i.title,
                                author: i.author ?? "unknown",
                                publisher: i.publisher ?? "unknown",
                                thumbnail: i.thumbnail!,
                                info: i.info,
                                link: i.link,
                                onClick: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext context) {
                                    return BookInfoPage(url: i.link);
                                  }));
                                },
                              ))
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
                    'assets/no_results.svg',
                    width: 200,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "No Results Found !",
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
          return CustomErrorWidget(
              error: error,
              stackTrace: _,
              onRefresh: () {
                // ignore: unused_result
                ref.refresh(searchProvider(searchQuery));
              });
        },
        loading: () {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 5, right: 5, top: 10),
                child: TitleText("Results"),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                        strokeCap: StrokeCap.round,
                      ),
                    ))
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
