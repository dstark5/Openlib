import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/components/archive_source_setting.dart';
import 'package:openlib/ui/components/error_widget.dart';

void main() {
  testWidgets('website setting validates, saves, and updates the active source',
      (tester) async {
    String? saved;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: Scaffold(body: ArchiveSourceSetting(
        savePreference: (value) async {
          saved = value;
        },
      ))),
    ));
    await tester.tap(find.text("Anna's Archive website"));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextFormField), 'http://bad.example/search');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an HTTPS website address without a path.'),
        findsOneWidget);
    expect(saved, isNull);
    await tester.enterText(
        find.byType(TextFormField), ' https://mirror.example/ ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, 'https://mirror.example');
    expect(container.read(archiveBaseUrlProvider), saved);
    expect(find.text('mirror.example'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed save keeps the previous website and allows retry',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
          home: Scaffold(
              body: ArchiveSourceSetting(
        savePreference: (_) async => throw Exception('disk full'),
      ))),
    ));
    await tester.tap(find.text("Anna's Archive website"));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextFormField), 'https://mirror.example');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
        container.read(archiveBaseUrlProvider), AnnasArchieve.defaultBaseUrl);
    expect(find.text('Could not save the website. Try again.'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('connection failure shows host and website setting action',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: Scaffold(
      body: CustomErrorWidget(
        error: ArchiveRequestException(
            url: 'https://mirror.example/search?q=Alice'),
        stackTrace: StackTrace.current,
        onRefresh: () {},
      ),
    ))));
    await tester.pumpAndSettle();
    expect(find.text('Cannot reach mirror.example'), findsOneWidget);
    expect(find.text('Change website'), findsOneWidget);
    expect(find.text('Stack Trace'), findsNothing);
    await tester.tap(find.text('Change website'));
    await tester.pumpAndSettle();
    expect(find.text("Anna's Archive website"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('browser check offers in-app completion and retry',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: Scaffold(
      body: CustomErrorWidget(
        error: ArchiveRequestException(
            url: 'https://mirror.example/search?q=Alice', needsBrowser: true),
        stackTrace: StackTrace.current,
        onRefresh: () {},
      ),
    ))));
    await tester.pumpAndSettle();
    expect(find.text('Complete the website check'), findsOneWidget);
    expect(find.text('Open page in app'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Stack Trace'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
