import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/state/state.dart';
import 'package:openlib/ui/components/download_windows_setting.dart';

void main() {
  testWidgets('download windows default off and can be saved on',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    bool? saved;
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: Scaffold(
            body: DownloadWindowsSetting(savePreference: (value) async {
          saved = value;
        })))));
    expect(container.read(showDownloadWindowsProvider), false);
    expect(find.text('Show download windows'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(saved, true);
    expect(container.read(showDownloadWindowsProvider), true);
  });
}
