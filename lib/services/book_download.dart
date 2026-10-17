import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/services/annas_archieve.dart';

enum DownloadPhase {
  resolving,
  needsWebsite,
  downloading,
  verifying,
  complete,
  failed,
  cancelled
}

class BookDownload {
  const BookDownload(this.book, this.phase,
      {this.received = 0, this.total = 0, this.message});
  final BookInfoData book;
  final DownloadPhase phase;
  final int received;
  final int total;
  final String? message;
  bool get active => {
        DownloadPhase.resolving,
        DownloadPhase.needsWebsite,
        DownloadPhase.downloading,
        DownloadPhase.verifying
      }.contains(phase);
}

class BookDownloadController extends StateNotifier<BookDownload?> {
  BookDownloadController(
      {required this.resolve,
      required this.transfer,
      required this.verify,
      required this.save,
      this.onSaved})
      : super(null);
  final Future<List<String>> Function(String) resolve;
  final Future<void> Function(
          BookInfoData, List<String>, void Function(int, int), CancelToken)
      transfer;
  final Future<bool> Function(BookInfoData) verify;
  final Future<void> Function(BookInfoData) save;
  final void Function(BookInfoData)? onSaved;
  CancelToken _cancel = CancelToken();
  int _generation = 0;

  Future<void> start(BookInfoData book, {bool showWebsite = false}) async {
    if (state?.active == true) return;
    final generation = ++_generation;
    _cancel = CancelToken();
    state = BookDownload(book,
        showWebsite ? DownloadPhase.needsWebsite : DownloadPhase.resolving);
    if (showWebsite) return;
    try {
      final mirrors = await resolve(book.mirror!);
      if (generation != _generation) return;
      await continueWithMirrors(mirrors);
    } on ArchiveRequestException catch (e) {
      if (generation != _generation) return;
      state = BookDownload(book,
          e.needsBrowser ? DownloadPhase.needsWebsite : DownloadPhase.failed,
          message: e.needsBrowser
              ? 'Website check needed'
              : 'Cannot reach the download website. Try again.');
    } catch (_) {
      if (generation == _generation) {
        state = BookDownload(book, DownloadPhase.failed,
            message: 'Could not prepare the download. Try again.');
      }
    }
  }

  Future<void> continueWithMirrors(List<String> mirrors) async {
    final book = state?.book;
    if (book == null || state?.active != true) return;
    final generation = _generation;
    try {
      state = BookDownload(book, DownloadPhase.downloading);
      await transfer(book, mirrors, (received, total) {
        if (generation == _generation && mounted) {
          state = BookDownload(book, DownloadPhase.downloading,
              received: received, total: total);
        }
      }, _cancel);
      if (generation != _generation) return;
      state = BookDownload(book, DownloadPhase.verifying);
      if (!await verify(book))
        throw StateError('File verification failed. Try another edition.');
      if (generation != _generation) return;
      await save(book);
      if (generation != _generation) return;
      onSaved?.call(book);
      state = BookDownload(book, DownloadPhase.complete);
    } catch (_) {
      if (generation == _generation) {
        state = BookDownload(book, DownloadPhase.failed,
            message: 'Download could not be completed or verified. Try again.');
      }
    }
  }

  void cancel() {
    ++_generation;
    _cancel.cancel();
    if (state != null)
      state = BookDownload(state!.book, DownloadPhase.cancelled);
  }

  void dismiss() {
    if (state?.active != true) state = null;
  }

  @override
  void dispose() {
    ++_generation;
    _cancel.cancel();
    super.dispose();
  }
}
