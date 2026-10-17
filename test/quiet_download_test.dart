import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/book_download.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/components/download_status.dart';
import 'package:openlib/ui/webview_page.dart';
import 'book_download_test.dart' show book;

void main() {
  testWidgets(
      'one tap downloads without windows and continues after leaving the page',
      (tester) async {
    final finish = Completer<void>();
    var saved = false;
    final controller = BookDownloadController(
        resolve: (_) async => ['https://files.example/alice.epub'],
        transfer: (_, __, ___, ____) => finish.future,
        verify: (_) async => true,
        save: (_) async {
          saved = true;
        });
    await tester.pumpWidget(ProviderScope(
        overrides: [
          bookDownloadProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
            home: Scaffold(
                body: Builder(
                    builder: (context) => Column(children: [
                          BookDownloadButton(book: book),
                          const DownloadStatusBar(),
                          TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Scaffold(
                                          body: Text('Browse other books')))),
                              child: const Text('Browse')),
                        ]))))));
    await tester.tap(find.text('Add To My Library'));
    await tester.pump();
    expect(find.text('Download started in background'), findsOneWidget);
    expect(find.byType(Webview), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('Browse'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Browse other books'), findsOneWidget);
    expect(controller.state!.phase, DownloadPhase.downloading);
    finish.complete();
    await tester.pump();
    expect(saved, true);
    expect(controller.state!.phase, DownloadPhase.complete);
    expect(tester.takeException(), isNull);
  });
}
