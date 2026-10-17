import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'archive_connection_test.dart' show StubAdapter, searchHtml;

void main() {
  test('browser-first mode skips the known blocked HTTP round trip', () async {
    final adapter =
        StubAdapter((_) async => throw StateError('Unnecessary HTTP request'));
    final service = AnnasArchieve(
        dio: Dio()..httpClientAdapter = adapter,
        preferBrowser: true,
        browserPageLoader: (_) async => searchHtml);
    expect((await service.searchBooks(searchQuery: 'Alice')).single.title,
        'Alice');
    expect(adapter.requests, isEmpty);
  });
}
