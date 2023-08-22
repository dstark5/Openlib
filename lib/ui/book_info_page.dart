import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class BookInfoPage extends ConsumerWidget {
  const BookInfoPage({Key? key, required this.url, required this.title})
      : super(key: key);

  final String url;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookInfo = ref.watch(bookInfoProvider(url));
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(title),
        titleSpacing: 0,
        // titleTextStyle: Theme.of(context).textTheme.displayLarge,
      ),
      body: bookInfo.when(
        data: (data) {
          return BookInfoWidget(
              data: data, child: ActionButtonWidget(data: data));
        },
        error: (err, _) {
          return CustomErrorWidget(
            error: err,
            stackTrace: _,
            onRefresh: () {
              // ignore: unused_result
              ref.refresh(bookInfoProvider(url));
            },
          );
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
            child: ElevatedButton(
              // style: ElevatedButton.styleFrom(
              //     // backgroundColor: Theme.of(context).colorScheme.secondary,
              //     textStyle: const TextStyle(
              //   // fontSize: 13,
              //   fontWeight: FontWeight.w500,
              //   // color: Colors.white,
              // )),
              onPressed: () async {
                await downloadFileWidget(ref, context, widget.data);
              },
              child: const Text('Add To My Library',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    // color: Colors.white,
                  )),
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

    return AlertDialog(
      title: const Text("Downloading Book"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          const SizedBox(
            height: 20,
          ),
          LinearProgressIndicator(
            value: downloadProgress,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            '$downloadedFileSize/$fileSize',
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            ref.read(cancelCurrentDownload).cancel();
            Navigator.pop(context, 'Cancel');
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
