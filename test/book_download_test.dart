import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/book_download.dart';

final book = BookInfoData(
    title: 'Alice',
    author: null,
    thumbnail: null,
    publisher: null,
    info: null,
    link: '/md5/abc',
    md5: 'abc',
    format: 'epub',
    mirror: 'https://mirror.example/slow_download/abc/0/0',
    description: null);

void main() {
  test('one tap resolves and downloads without saving an incomplete file',
      () async {
    final finish = Completer<void>();
    var saved = false;
    final controller = BookDownloadController(
        resolve: (_) async => ['https://files.example/alice.epub'],
        transfer: (data, mirrors, progress, cancel) => finish.future,
        verify: (_) async => true,
        save: (_) async {
          saved = true;
        });
    addTearDown(controller.dispose);
    final task = controller.start(book);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state!.phase, DownloadPhase.downloading);
    expect(saved, false);
    finish.complete();
    await task;
    expect(saved, true);
    expect(controller.state!.phase, DownloadPhase.complete);
  });

  test('a required check waits for user input and can then continue', () async {
    final controller = BookDownloadController(
        resolve: (url) async =>
            throw ArchiveRequestException(url: url, needsBrowser: true),
        transfer: (_, __, ___, ____) async {},
        verify: (_) async => true,
        save: (_) async {});
    addTearDown(controller.dispose);
    await controller.start(book);
    expect(controller.state!.phase, DownloadPhase.needsWebsite);
    await controller.continueWithMirrors(['https://files.example/alice.epub']);
    expect(controller.state!.phase, DownloadPhase.complete);
  });

  test('failed verification never adds the book to the library', () async {
    var saved = false;
    final controller = BookDownloadController(
        resolve: (_) async => ['https://files.example/alice.epub'],
        transfer: (_, __, ___, ____) async {},
        verify: (_) async => false,
        save: (_) async {
          saved = true;
        });
    addTearDown(controller.dispose);
    await controller.start(book);
    expect(saved, false);
    expect(controller.state!.phase, DownloadPhase.failed);
  });

  test('cancelling while resolving prevents a later download', () async {
    final mirrors = Completer<List<String>>();
    var transferred = false;
    final controller = BookDownloadController(
        resolve: (_) => mirrors.future,
        transfer: (_, __, ___, ____) async {
          transferred = true;
        },
        verify: (_) async => true,
        save: (_) async {});
    addTearDown(controller.dispose);
    final task = controller.start(book);
    controller.cancel();
    mirrors.complete(['https://files.example/alice.epub']);
    await task;
    expect(transferred, false);
    expect(controller.state!.phase, DownloadPhase.cancelled);
  });
}
