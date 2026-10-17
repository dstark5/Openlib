import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/state/state.dart';

class DownloadWindowsSetting extends ConsumerWidget {
  const DownloadWindowsSetting({super.key, this.savePreference});
  final Future<void> Function(bool)? savePreference;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
      child: SwitchListTile(
        tileColor: Theme.of(context).colorScheme.tertiaryContainer,
        activeColor: Theme.of(context).colorScheme.secondary,
        title: const Text('Show download windows'),
        subtitle: const Text('Off: download quietly while you browse.'),
        value: ref.watch(showDownloadWindowsProvider),
        onChanged: (value) async {
          try {
            await (savePreference?.call(value) ??
                MyLibraryDb.instance
                    .savePreference('showDownloadWindows', value));
            ref.read(showDownloadWindowsProvider.notifier).state = value;
          } catch (_) {
            if (context.mounted)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Could not save the download setting.')));
          }
        },
      ));
}
