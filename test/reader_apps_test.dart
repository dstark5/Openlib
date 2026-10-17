import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/services/reader_apps.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  test('lists compatible installed readers with meaningful labels', () async {
    final apps = await const ReaderApps().installedReaders('epub');
    expect(calls.single.arguments, {'mimeType': 'application/epub+zip'});
    expect(apps.first.id, 'com.flyersoft.moonreaderp');
    expect(apps.first.label, 'Moon+ Reader Pro');
    expect(apps.last.requiresImport, isTrue);
  });

  test('opens the selected app with the correct file and MIME type', () async {
    await const ReaderApps().openBook(
        path: '/books/abc.epub',
        format: 'epub',
        reader: 'com.flyersoft.moonreaderp',
        title: 'Ubik');
    expect(calls.single.method, 'open');
    expect(calls.single.arguments, {
      'path': '/books/abc.epub',
      'mimeType': 'application/epub+zip',
      'reader': 'com.flyersoft.moonreaderp',
      'displayName': 'Ubik.epub',
    });
  });

  test('ask every time explicitly requests the system chooser', () async {
    await const ReaderApps()
        .openBook(path: '/books/book.pdf', format: 'pdf', reader: 'ask');
    expect(calls.single.arguments['reader'], 'ask');
    expect(calls.single.arguments['mimeType'], 'application/pdf');
  });
}
