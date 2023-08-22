import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'extensions.dart';
import 'package:openlib/ui/components/page_title_widget.dart';
import 'package:openlib/ui/components/error_widget.dart';
import 'package:openlib/ui/results_page.dart';
import 'package:openlib/state/state.dart' show getTrendingBooks;

class TrendingPage extends ConsumerWidget {
  const TrendingPage({super.key});

  final double imageHeight = 145;
  final double imageWidth = 105;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingBooks = ref.watch(getTrendingBooks);
    return trendingBooks.when(data: (data) {
      return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 0),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: TitleText("Trending"),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(5),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 13.0,
                  mainAxisExtent: 205,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return ResultPage(
                            searchQuery: data[index].title!,
                          );
                        }));
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CachedNetworkImage(
                              height: imageHeight,
                              width: imageWidth,
                              imageUrl: data[index].thumbnail!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  // color: "#E3E8E9".toColor(),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                ),
                                height: imageHeight,
                                width: imageWidth,
                              ),
                              errorWidget: (context, url, error) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                  ),
                                  height: imageHeight,
                                  width: imageWidth,
                                  child: const Center(
                                    child: Icon(Icons.image_rounded),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SizedBox(
                                width: imageWidth,
                                child: Text(
                                  data[index].title!,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ]),
                    );
                  },
                  childCount: data.length,
                ),
              ),
            ),
          ],
        ),
      );
    }, error: (error, _) {
      return CustomErrorWidget(
        error: error,
        stackTrace: _,
        onRefresh: () {
          // ignore: unused_result
          ref.refresh(getTrendingBooks);
        },
      );
    }, loading: () {
      return const Center(
          child: SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(
            // color: Theme.of(context).colorScheme.secondary,
            ),
      ));
    });
  }
}
