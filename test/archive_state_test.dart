import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/state/state.dart';

import 'archive_connection_test.dart' show searchHtml, detailHtml;

void main() {
  test(
      'browser results return to search and details using the selected website',
      () async {
    final container = ProviderContainer(overrides: [
      archiveBaseUrlProvider.overrideWith((ref) => 'https://mirror.example'),
    ]);
    addTearDown(container.dispose);
    final service = AnnasArchieve(baseUrl: 'https://mirror.example');
    final url = service.urlEncoder(
        searchQuery: 'Alice',
        content: '',
        sort: '',
        fileType: '',
        enableFilters: true);
    container.read(archiveBrowserPagesProvider.notifier).state = {
      url: searchHtml,
      'https://mirror.example/md5/abc123': detailHtml,
    };
    final books = await container.read(searchProvider('Alice').future);
    expect(books.single.title, 'Alice');
    final details = await container
        .read(bookInfoProvider('https://annas-archive.org/md5/abc123').future);
    expect(details.title, 'Alice');
    expect(details.mirror, 'https://mirror.example/slow_download/abc123/0/0');
  });
}
