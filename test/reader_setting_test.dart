import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/components/reader_app_setting.dart';
import 'package:openlib/ui/components/file_buttons_widget.dart';

void main() {
  const channel = MethodChannel('openlib/readers');
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'readers')
        return [
          {'id': 'com.flyersoft.moonreaderp', 'label': 'Moon+ Reader Pro'},
          {
            'id': 'com.tct.book',
            'label': 'TCL Bookshelf',
            'requiresImport': true
          },
        ];
      return null;
    });
  });
  tearDown(() => TestDefaultBinaryMessengerBinding
      .instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));

  testWidgets('reader choice is visible, persisted, and used by library Open',
      (tester) async {
    final container = ProviderContainer(overrides: [
      filePathProvider('abc.epub')
          .overrideWith((ref) async => '/books/abc.epub'),
    ]);
    addTearDown(container.dispose);
    final saved = <String, String>{};
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
          home: Scaffold(
              body: Column(children: [
        ReaderAppSetting(
            format: 'epub',
            savePreference: (name, value) async {
              saved[name] = value;
            }),
        FileOpenAndDeleteButtons(
            id: 'abc', format: 'epub', title: 'Ubik', onDelete: () {}),
      ]))),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open EPUBs with'));
    await tester.pumpAndSettle();
    expect(find.text('Openlib reader'), findsWidgets);
    expect(find.text('Ask every time'), findsOneWidget);
    expect(find.text('TCL Bookshelf'), findsOneWidget);
    expect(find.text('Import from Download/Openlib after opening Bookshelf.'),
        findsOneWidget);
    await tester.tap(find.text('Moon+ Reader Pro').last);
    await tester.pumpAndSettle();
    expect(saved['epubReaderApp'], 'com.flyersoft.moonreaderp');
    expect(container.read(readerPreferenceProvider('epub')),
        'com.flyersoft.moonreaderp');
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final open = calls.where((c) => c.method == 'open').single;
    expect(open.arguments['reader'], 'com.flyersoft.moonreaderp');
    expect(open.arguments['path'], '/books/abc.epub');
    expect(open.arguments['displayName'], 'Ubik.epub');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed preference save leaves the working choice selected',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
          home: Scaffold(
              body: ReaderAppSetting(
        format: 'epub',
        savePreference: (_, __) async => throw Exception('disk full'),
      ))),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open EPUBs with'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Moon+ Reader Pro').last);
    await tester.pumpAndSettle();
    expect(container.read(readerPreferenceProvider('epub')), 'internal');
    expect(find.text('Could not save the reader. Try again.'), findsOneWidget);
  });
}
