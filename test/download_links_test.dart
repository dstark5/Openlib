import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/archive_download.dart';

void main() {
  test(
      'extracts a ready slow-download file without treating navigation as a mirror',
      () {
    final links = archiveDownloadLinks(
        '''<p class="mb-4 text-xl font-bold"><a href="https://files.example/book.epub">Download</a></p>
      <ul><li><a href="/search">Search</a></li></ul>''',
        'https://annas-archive.gl/slow_download/abc/0/0');
    expect(links, ['https://files.example/book.epub']);
  });
  test('a slow-download wait page does not turn external navigation into files', () {
    expect(archiveDownloadLinks('<ul><li><a href="https://example.org/about">About</a></li></ul>',
      'https://annas-archive.gl/slow_download/abc/0/0'), isEmpty);
  });
  test('a challenge or waiting page has no downloadable links', () {
    expect(
        archiveDownloadLinks('<title>DDoS-Guard</title>',
            'https://annas-archive.gl/slow_download/abc/0/0'),
        isEmpty);
  });
}
