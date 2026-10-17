import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/annas_archieve.dart';

void main() {
  test('search omits empty filters instead of requesting empty filter values', () {
    final url = Uri.parse(AnnasArchieve().urlEncoder(searchQuery: 'Ubik',
        content: '', sort: '', fileType: '', enableFilters: true));
    expect(url.queryParameters, {'q': 'Ubik'});
  });

  test('search preserves reserved characters and selected filters', () {
    final url = Uri.parse(AnnasArchieve().urlEncoder(searchQuery: 'A&B + C?',
        content: 'book_fiction', sort: 'newest', fileType: 'epub', enableFilters: true));
    expect(url.queryParameters, {
      'q': 'A&B + C?', 'content': 'book_fiction', 'ext': 'epub', 'sort': 'newest',
    });
  });

  test('disabled filters include only the search query', () {
    final url = Uri.parse(AnnasArchieve().urlEncoder(searchQuery: 'Ubik',
        content: 'book_fiction', sort: 'newest', fileType: 'epub', enableFilters: false));
    expect(url.queryParameters, {'q': 'Ubik'});
  });

  test('accepts the website browser-check redirect observed on the TCL', () {
    expect(AnnasArchieve.matchesRequestedPage(
      'https://annas-archive.gl/search?index=&q=Ubik&content=&ext=&sort=',
      'https://annas-archive.gl/search?index=&q=ubik&content=&ext=&sort=&check=1',
    ), isTrue);
    expect(AnnasArchieve.matchesRequestedPage(
      'https://annas-archive.gl/search?q=Ubik&ext=epub',
      'https://annas-archive.gl/search?check=1&ext=epub&q=ubik',
    ), isTrue);
  });

  test('does not import a different search, filter, book, or website', () {
    const requested = 'https://annas-archive.gl/search?q=Ubik&ext=epub';
    for (final other in [
      'https://annas-archive.gl/search?q=Alice&ext=epub&check=1',
      'https://annas-archive.gl/search?q=ubik&ext=pdf&check=1',
      'https://annas-archive.gl/md5/book?q=ubik&ext=epub',
      'https://other.example/search?q=ubik&ext=epub&check=1',
      'about:blank',
    ]) {
      expect(AnnasArchieve.matchesRequestedPage(requested, other), isFalse,
          reason: other);
    }
  });
}
