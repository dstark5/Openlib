// Dart imports:
// import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/services/share_book.dart';
// import 'package:flutter_svg/svg.dart';

// Project imports:
import 'package:openlib/services/annas_archieve.dart' show BookInfoData;
import 'package:openlib/ui/components/book_info_widget.dart';
import 'package:openlib/ui/components/error_widget.dart';
import 'package:openlib/ui/components/file_buttons_widget.dart';
import 'package:openlib/ui/components/download_status.dart';

import 'package:openlib/state/state.dart' show bookInfoProvider, checkIdExists;

class BookInfoPage extends ConsumerWidget {
  const BookInfoPage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookInfo = ref.watch(bookInfoProvider(url));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Openlib"),
        titleTextStyle: Theme.of(context).textTheme.displayLarge,
        actions: [
          bookInfo.maybeWhen(data: (data) {
            return IconButton(
              icon: Icon(
                Icons.share_sharp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              iconSize: 19.0,
              onPressed: () async {
                await shareBook(data.title, data.link, data.thumbnail ?? '');
              },
            );
          }, orElse: () {
            return const SizedBox.shrink();
          })
        ],
      ),
      bottomNavigationBar: const DownloadStatusBar(),
      body: bookInfo.when(
        skipLoadingOnRefresh: false,
        data: (data) {
          return BookInfoWidget(
              data: data, child: ActionButtonWidget(data: data));
        },
        error: (err, _) {
          // if (err.toString().contains("403")) {
          //   var errJson = jsonDecode(err.toString());

          //   if (SchedulerBinding.instance.schedulerPhase ==
          //       SchedulerPhase.persistentCallbacks) {
          //     SchedulerBinding.instance.addPostFrameCallback((_) {
          //       Future.delayed(
          //           const Duration(seconds: 3),
          //           () => Navigator.pushReplacement(context,
          //                   MaterialPageRoute(builder: (BuildContext context) {
          //                 return Webview(url: errJson["url"]);
          //               })));
          //     });
          //   }

          //   return Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       SizedBox(
          //         width: 210,
          //         child: SvgPicture.asset(
          //           'assets/captcha.svg',
          //           width: 210,
          //         ),
          //       ),
          //       const SizedBox(
          //         height: 30,
          //       ),
          //       Text(
          //         "Captcha required",
          //         textAlign: TextAlign.center,
          //         style: TextStyle(
          //           fontSize: 18,
          //           fontWeight: FontWeight.bold,
          //           color: Theme.of(context).textTheme.headlineMedium?.color,
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Text(
          //           "you will be redirected to solve captcha",
          //           textAlign: TextAlign.center,
          //           style: TextStyle(
          //             fontSize: 13,
          //             fontWeight: FontWeight.bold,
          //             color: Theme.of(context).textTheme.headlineSmall?.color,
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.fromLTRB(30, 15, 30, 10),
          //         child: Container(
          //           width: double.infinity,
          //           decoration: BoxDecoration(
          //               color: const Color.fromARGB(255, 255, 186, 186),
          //               borderRadius: BorderRadius.circular(5)),
          //           child: const Padding(
          //             padding: EdgeInsets.all(10.0),
          //             child: Text(
          //               "If you have solved the captcha then you will be automatically redirected to the results page . In case you seeing this page even after completing try using a VPN .",
          //               textAlign: TextAlign.start,
          //               style: TextStyle(
          //                 fontSize: 13,
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.black,
          //               ),
          //             ),
          //           ),
          //         ),
          //       )
          //     ],
          //   );
          // } else {
          return CustomErrorWidget(
            error: err,
            stackTrace: _,
            onRefresh: () {
              // ignore: unused_result
              ref.refresh(bookInfoProvider(url));
            },
          );
          // }
        },
        loading: () {
          return Center(
              child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
              strokeCap: StrokeCap.round,
            ),
          ));
        },
      ),
    );
  }
}

class ActionButtonWidget extends ConsumerWidget {
  const ActionButtonWidget({super.key, required this.data});
  final BookInfoData data;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(checkIdExists(data.md5)).when(
          data: (exists) => exists
              ? FileOpenAndDeleteButtons(
                  id: data.md5,
                  title: data.title,
                  format: data.format!,
                  onDelete: () => ref.invalidate(checkIdExists(data.md5)))
              : BookDownloadButton(book: data),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Could not read the library.'),
        );
  }
}
