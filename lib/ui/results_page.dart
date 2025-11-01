// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:openlib/state/state.dart' as app_state;
import 'package:openlib/ui/book_info_page.dart';
import 'package:openlib/ui/components/book_card_widget.dart';
import 'package:openlib/ui/components/error_widget.dart';
// NOTE: Assuming the class INSIDE this file is named TitleText.
import 'package:openlib/ui/components/page_title_widget.dart'; 
import 'package:openlib/ui/extensions.dart';

// A constant for the 'No Results Found' text color for better theming/readability.
const Color _kNoResultsTextColor = Color(0xFF4D4D4D);

// Custom extension for String to add the missing capitalizeFirst method
extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key, required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchBooks = ref.watch(app_state.searchProvider(searchQuery));
    final String capitalizedQuery = searchQuery.capitalizeFirst;

    return Scaffold(
      appBar: AppBar(
        title: Text("Results for '$capitalizedQuery'"),
        titleTextStyle:
            Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: searchBooks.when(
        // ====================================================================
        // DATA STATE
        // ====================================================================
        data: (data) {
          if (data.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      // FIX 1: Changed PageTitleWidget back to TitleText
                      child: TitleText("Results"), 
                    ),
                  ),
                  SliverList.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final i = data[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: BookInfoCard(
                          title: i.title,
                          author: i.author ?? "unknown",
                          publisher: i.publisher ?? "unknown",
                          thumbnail: i.thumbnail ?? '',
                          info: i.info ?? '',
                          link: i.link,
                          onClick: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return BookInfoPage(url: i.link);
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            // No Results Found UI
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: SvgPicture.asset(
                        'assets/no_results.svg',
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "No Results Found !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _kNoResultsTextColor,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        },

        // ====================================================================
        // ERROR STATE
        // ====================================================================
        error: (error, stackTrace) {
          return CustomErrorWidget(
            error: error,
            stackTrace: stackTrace,
            onRefresh: () {
              // ignore: unused_result
              ref.refresh(app_state.searchProvider(searchQuery));
            },
          );
        },

        // ====================================================================
        // LOADING STATE
        // ====================================================================
        loading: () {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                // FIX 2: Changed PageTitleWidget back to TitleText
                child: TitleText("Results"),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                      strokeWidth: 3.0,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}