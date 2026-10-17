import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/download_file.dart';
import 'archive_connection_test.dart' show StubAdapter;

void main() {
  test('a single mirror starts without an artificial wait or HEAD request',
      () async {
    final adapter =
        StubAdapter((_) async => throw StateError('No probe needed'));
    expect(
        await selectDownloadMirror(['https://files.example/book'],
            dio: Dio()..httpClientAdapter = adapter),
        'https://files.example/book');
    expect(adapter.requests, isEmpty);
  });
  test('a slow first mirror does not hold up a working second mirror',
      () async {
    final slow = Completer<ResponseBody>();
    final adapter = StubAdapter((request) => request.uri.host == 'slow.example'
        ? slow.future
        : Future.value(ResponseBody.fromString('', 200)));
    final selected = await selectDownloadMirror(
            ['https://slow.example/book', 'https://fast.example/book'],
            dio: Dio()..httpClientAdapter = adapter)
        .timeout(const Duration(seconds: 1));
    expect(selected, 'https://fast.example/book');
    slow.complete(ResponseBody.fromString('', 500));
  });
}
