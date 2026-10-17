import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'archive_connection_test.dart' show StubAdapter, searchHtml, detailHtml;

void main() {
  test('blocked requests reuse the browser session for search and details',
      () async {
    final adapter = StubAdapter((_) async => ResponseBody.fromString('', 403));
    final loaded = <String>[];
    final service = AnnasArchieve(
        dio: Dio()..httpClientAdapter = adapter,
        browserPageLoader: (url) async {
          loaded.add(url);
          return Uri.parse(url).path == '/search' ? searchHtml : detailHtml;
        });
    final books = await service.searchBooks(searchQuery: 'Alice');
    final book = await service.bookInfo(url: books.single.link);
    expect(book.title, 'Alice');
    expect(loaded, ['${service.baseUrl}/search?q=Alice', books.single.link]);
  });

  test('successful HTTP requests do not start another browser', () async {
    final adapter =
        StubAdapter((_) async => ResponseBody.fromString(searchHtml, 200));
    final service = AnnasArchieve(
        dio: Dio()..httpClientAdapter = adapter,
        browserPageLoader: (_) async =>
            throw StateError('No browser expected'));
    expect((await service.searchBooks(searchQuery: 'Alice')).single.title,
        'Alice');
  });

  test('an expired browser session still offers a manual check', () async {
    final adapter = StubAdapter((_) async => ResponseBody.fromString('', 403));
    final service = AnnasArchieve(
        dio: Dio()..httpClientAdapter = adapter,
        browserPageLoader: (_) async => '<title>DDoS-Guard</title>');
    await expectLater(
        service.searchBooks(searchQuery: 'Alice'),
        throwsA(isA<ArchiveRequestException>()
            .having((e) => e.needsBrowser, 'needsBrowser', true)));
  });
}
