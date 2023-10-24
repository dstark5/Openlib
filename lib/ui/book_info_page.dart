import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';

import 'package:openlib/services/database.dart';
import 'package:openlib/ui/components/error_widget.dart';
import 'package:openlib/services/download_file.dart';
import 'package:openlib/services/annas_archieve.dart' show BookInfoData;
import 'package:openlib/state/state.dart'
    show
        bookInfoProvider,
        totalFileSizeInBytes,
        downloadedFileSizeInBytes,
        downloadProgressProvider,
        getTotalFileSize,
        getDownloadedFileSize,
        cancelCurrentDownload,
        dbProvider,
        checkIdExists,
        myLibraryProvider;
import 'package:openlib/ui/components/book_info_widget.dart';
import 'package:openlib/ui/components/file_buttons_widget.dart';
import 'package:openlib/ui/components/snack_bar_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openlib/ui/webview_page.dart';

class BookInfoPage extends ConsumerWidget {
  const BookInfoPage({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookInfo = ref.watch(bookInfoProvider(url));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Openlib"),
        titleTextStyle: Theme.of(context).textTheme.displayLarge,
      ),
      body: bookInfo.when(
        skipLoadingOnRefresh: false,
        data: (data) {
          return BookInfoWidget(
              data: data, child: ActionButtonWidget(data: data));
        },
        error: (err, _) {
          // print(err);
          if (err.toString().contains("403")) {
            var errJson = jsonDecode(err.toString());
            if (SchedulerBinding.instance.schedulerPhase ==
                SchedulerPhase.persistentCallbacks) {
              SchedulerBinding.instance.addPostFrameCallback((_) async {
                await Future.delayed(const Duration(seconds: 2));
                // ignore: use_build_context_synchronously
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return Webview(url: errJson["url"]);
                })).then((value) {
                  // print("got Cf Clearance");
                  // ignore: unused_result
                  ref.refresh(bookInfoProvider(url));
                  // });
                });
              });
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 210,
                  child: SvgPicture.asset(
                    'assets/captcha.svg',
                    width: 210,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "Captcha required",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "you will be redirected to solve captcha",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 10),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 186, 186),
                        borderRadius: BorderRadius.circular(5)),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "If you have solved the captcha then you will be automatically redirected to the book page",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return CustomErrorWidget(
              error: err,
              stackTrace: _,
              onRefresh: () {
                // ignore: unused_result
                ref.refresh(bookInfoProvider(url));
              },
            );
          }
        },
        loading: () {
          return Center(
              child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ));
        },
      ),
    );
  }
}

class ActionButtonWidget extends ConsumerStatefulWidget {
  const ActionButtonWidget({super.key, required this.data});
  final BookInfoData data;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ActionButtonWidgetState();
}

class _ActionButtonWidgetState extends ConsumerState<ActionButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final isBookExist = ref.watch(checkIdExists(widget.data.md5));

    return isBookExist.when(
      data: (isExists) {
        if (isExists) {
          return FileOpenAndDeleteButtons(
            id: widget.data.md5,
            format: widget.data.format!,
            onDelete: () async {
              await Future.delayed(const Duration(seconds: 1));
              // ignore: unused_result
              ref.refresh(checkIdExists(widget.data.md5));
            },
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 21, bottom: 21),
            child: TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  )),
              onPressed: () async {
                await downloadFileWidget(ref, context, widget.data);
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Add To My Library'),
              ),
            ),
          );
        }
      },
      error: (error, stackTrace) {
        return Text(error.toString());
      },
      loading: () {
        return CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
        );
      },
    );
  }
}

Future<void> downloadFileWidget(
    WidgetRef ref, BuildContext context, dynamic data) async {
  downloadFile(
      mirrors: data.mirrors!,
      md5: data.md5,
      format: data.format!,
      onProgress: (int rcv, int total) async {
        if (ref.read(totalFileSizeInBytes) != total) {
          ref.read(totalFileSizeInBytes.notifier).state = total;
        }
        ref.read(downloadedFileSizeInBytes.notifier).state = rcv;
        ref.read(downloadProgressProvider.notifier).state = rcv / total;
        if (rcv / total == 1.0) {
          await ref.read(dbProvider).insert(MyBook(
              id: data.md5,
              title: data.title,
              author: data.author,
              thumbnail: data.thumbnail,
              link: data.link,
              publisher: data.publisher,
              info: data.info,
              format: data.format,
              description: data.description));

          // ignore: unused_result
          ref.refresh(checkIdExists(data.md5));
          // ignore: unused_result
          ref.refresh(myLibraryProvider);
          // ignore: use_build_context_synchronously
          showSnackBar(context: context, message: 'Book has been downloaded!');
        }
      },
      cancelDownlaod: (CancelToken downloadToken) {
        ref.read(cancelCurrentDownload.notifier).state = downloadToken;
      },
      onDownlaodFailed: () {
        Navigator.of(context).pop();
        showSnackBar(
            context: context, message: 'downloaded Failed! try again...');
      });

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _ShowDialog(title: data.title);
      });
}

class _ShowDialog extends ConsumerWidget {
  final String title;

  const _ShowDialog({required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadProgress = ref.watch(downloadProgressProvider);
    final fileSize = ref.watch(getTotalFileSize);
    final downloadedFileSize = ref.watch(getDownloadedFileSize);

    if (downloadProgress == 1.0) {
      Navigator.of(context).pop();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: double.infinity,
            height: 255,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.tertiaryContainer,
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Downloading Book",
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withAlpha(170),
                          decoration: TextDecoration.none),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '$downloadedFileSize/$fileSize',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                              decoration: TextDecoration.none,
                              letterSpacing: 1),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      child: LinearProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withAlpha(50),
                        value: downloadProgress,
                        minHeight: 4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              textStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              )),
                          onPressed: () {
                            ref.read(cancelCurrentDownload).cancel();
                            Navigator.of(context).pop();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text('Cancel'),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
