import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/search_page.dart';
import 'archive_connection_test.dart' show searchHtml;

void main() {
  test('language filters reach the website and are omitted for all languages',
      () {
    final service = AnnasArchieve();
    String url(String language, bool filters) => service.urlEncoder(
        searchQuery: 'Alice',
        content: '',
        sort: '',
        fileType: '',
        enableFilters: filters,
        language: language);
    expect(Uri.parse(url('de', true)).queryParameters['lang'], 'de');
    expect(Uri.parse(url('', true)).queryParameters.containsKey('lang'), false);
    expect(
        Uri.parse(url('en', false)).queryParameters.containsKey('lang'), false);
  });

  test('search uses language in both its cache key and request', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(selectedLanguageState.notifier).state = 'de';
    container.read(archiveBrowserPagesProvider.notifier).state = {
      '${AnnasArchieve.defaultBaseUrl}/search?q=Alice&lang=de': searchHtml,
    };
    expect((await container.read(searchProvider('Alice').future)).single.title,
        'Alice');
  });

  testWidgets('search exposes a language control with readable choices',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SearchPage()))));
    await tester.ensureVisible(find.text('Language'));
    await tester.tap(find.text('All languages'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('German').last);
    await tester.pumpAndSettle();
    expect(container.read(selectedLanguageState), 'de');
  });
}
