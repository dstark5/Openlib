import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/annas_archieve.dart';

void main() {
  test('parses the actual search result markup captured on the TCL', () async {
    final html = File('test/fixtures/annas_archive_search.html').readAsStringSync();
    final books = await AnnasArchieve().searchBooks(
        searchQuery: 'Ubik', fileType: 'epub', pageHtml: html);
    expect(books, hasLength(2));
    expect(books.map((book) => book.title), everyElement('Ubik'));
    expect(books.map((book) => book.info), everyElement(contains('EPUB')));
    expect(books.map((book) => book.link),
        everyElement(startsWith('https://annas-archive.gl/md5/')));
    expect(books.map((book) => book.author), everyElement(isNotEmpty));
  });
}
