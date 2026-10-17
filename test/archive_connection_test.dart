import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/annas_archieve.dart';

const searchHtml = '''
<div class="main-inner">
<div class="flex pt-3 pb-3 border-b">
  <a class="line-clamp-[3] js-vim-focus" href="/md5/abc123">Alice</a>
  <a href="/search?q=Carroll">Lewis Carroll</a>
  <a href="/search?q=Publisher">Publisher</a>
  <div class="text-gray-800">English, EPUB</div>
</div>
</div>
''';

const detailHtml = '''
<div class="main-inner">
  <div class="font-semibold text-2xl">Alice</div>
  <a class="text-base" href="/search?q=Carroll">Lewis Carroll</a>
  <div class="text-gray-800">English, EPUB</div>
  <ul class="list-inside"><li><a href="/slow_download/abc123/0/0">Download</a></li></ul>
</div>
''';

class StubAdapter implements HttpClientAdapter {
  StubAdapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  final List<Uri> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) {
    requests.add(options.uri);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Archive website', () {
    test('uses the current default origin', () {
      expect(AnnasArchieve().baseUrl, 'https://annas-archive.gl');
    });

    test('normalizes an HTTPS origin and rejects non-origin input', () {
      expect(AnnasArchieve.normalizeBaseUrl(' https://mirror.example/ '),
          'https://mirror.example');
      for (final invalid in [
        '',
        'mirror.example',
        'http://mirror.example',
        'https://',
        'https://bad host.example',
        'https://user:password@mirror.example',
        'https://mirror.example/search',
        'https://mirror.example/?q=book',
        'https://mirror.example/#fragment',
      ]) {
        expect(() => AnnasArchieve.normalizeBaseUrl(invalid),
            throwsFormatException,
            reason: invalid);
      }
    });

    test('moves saved Anna links to the selected origin, preserving the path',
        () {
      final service = AnnasArchieve(baseUrl: 'https://mirror.example');
      expect(service.resolveUrl('https://annas-archive.org/md5/abc123?x=1'),
          'https://mirror.example/md5/abc123?x=1');
      expect(service.resolveUrl('/slow_download/abc123/0/0'),
          'https://mirror.example/slow_download/abc123/0/0');
      expect(service.resolveUrl('https://files.example/alice.epub'),
          'https://files.example/alice.epub');
    });

    test('uses the selected origin for requests, results, and download pages',
        () async {
      final adapter = StubAdapter((options) async => ResponseBody.fromString(
          options.uri.path == '/search' ? searchHtml : detailHtml, 200));
      final client = Dio()..httpClientAdapter = adapter;
      final service =
          AnnasArchieve(baseUrl: 'https://mirror.example', dio: client);
      final books = await service.searchBooks(searchQuery: 'Alice');
      expect(adapter.requests.single.host, 'mirror.example');
      expect(books.single.link, 'https://mirror.example/md5/abc123');
      final book =
          await service.bookInfo(url: 'https://annas-archive.org/md5/abc123');
      expect(adapter.requests.last.toString(),
          'https://mirror.example/md5/abc123');
      expect(book.link, 'https://mirror.example/md5/abc123');
      expect(book.mirror, 'https://mirror.example/slow_download/abc123/0/0');
    });
  });

  group('Recovery', () {
    test('DNS failure reports the requested website without losing the cause',
        () async {
      final adapter = StubAdapter((options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Failed host lookup'));
      final client = Dio()..httpClientAdapter = adapter;
      final service =
          AnnasArchieve(baseUrl: 'https://mirror.example', dio: client);
      await expectLater(
          service.searchBooks(searchQuery: 'Alice'),
          throwsA(isA<ArchiveRequestException>()
              .having((e) => e.needsBrowser, 'needsBrowser', false)
              .having((e) => e.url, 'url', contains('mirror.example/search'))
              .having((e) => e.cause, 'cause', isA<DioException>())));
    });

    test('server failure offers retry without exposing a raw Dio exception', () async {
      final adapter = StubAdapter((_) async => ResponseBody.fromString('', 502));
      final service = AnnasArchieve(dio: Dio()..httpClientAdapter = adapter);
      await expectLater(service.searchBooks(searchQuery: 'Dmt'),
        throwsA(isA<ArchiveRequestException>()
          .having((e) => e.needsBrowser, 'needsBrowser', false)
          .having((e) => (e.cause as DioException).response?.statusCode, 'status', 502)));
    });

    test('HTTP 403 offers a browser check instead of an empty result',
        () async {
      final adapter = StubAdapter((options) async =>
          ResponseBody.fromString('<title>DDoS-Guard</title>', 403));
      final service = AnnasArchieve(dio: Dio()..httpClientAdapter = adapter);
      await expectLater(
          service.searchBooks(searchQuery: 'Alice'),
          throwsA(isA<ArchiveRequestException>()
              .having((e) => e.needsBrowser, 'needsBrowser', true)));
    });

    test('a challenge returned with HTTP 200 is not treated as no books',
        () async {
      final adapter = StubAdapter((options) async => ResponseBody.fromString(
          '<title>DDoS-Guard</title><script src="/.well-known/ddos-guard/js-challenge/index.js"></script>',
          200));
      final service = AnnasArchieve(dio: Dio()..httpClientAdapter = adapter);
      await expectLater(
          service.searchBooks(searchQuery: 'Alice'),
          throwsA(isA<ArchiveRequestException>()
              .having((e) => e.needsBrowser, 'needsBrowser', true)));
    });

    test('uses a page loaded by the user without another blocked HTTP request',
        () async {
      final adapter = StubAdapter(
          (options) async => throw StateError('No request expected'));
      final service = AnnasArchieve(dio: Dio()..httpClientAdapter = adapter);
      final books =
          await service.searchBooks(searchQuery: 'Alice', pageHtml: searchHtml);
      final book =
          await service.bookInfo(url: books.single.link, pageHtml: detailHtml);
      expect(books.single.title, 'Alice');
      expect(book.mirror, contains('/slow_download/abc123/0/0'));
      expect(adapter.requests, isEmpty);
    });

    test('does not accept a browser challenge as a loaded archive page', () {
      expect(AnnasArchieve.isArchivePage(searchHtml), isTrue);
      expect(AnnasArchieve.isArchivePage(detailHtml), isTrue);
      expect(AnnasArchieve.isArchivePage('<title>DDoS-Guard</title>'), isFalse);
      expect(
          AnnasArchieve.isArchivePage('<html>unrelated page</html>'), isFalse);
    });
  });
}
