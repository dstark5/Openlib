import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlib/state/state.dart';
import 'archive_connection_test.dart' show searchHtml;

void main() {
  test('returning to the same search reuses recent results', () async {
    var loads = 0;
    final container = ProviderContainer(overrides: [
      archivePageLoaderProvider.overrideWithValue((_) async {
        loads++;
        return searchHtml;
      }),
    ]);
    addTearDown(container.dispose);
    final first = container.listen(searchProvider('Alice'), (_, __) {});
    await container.read(searchProvider('Alice').future);
    first.close();
    await container.pump();
    final second = container.listen(searchProvider('Alice'), (_, __) {});
    await container.read(searchProvider('Alice').future);
    second.close();
    expect(loads, 1);
  });
}
