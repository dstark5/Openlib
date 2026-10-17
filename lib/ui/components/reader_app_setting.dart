import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/reader_apps.dart';
import 'package:openlib/state/state.dart';

class ReaderAppSetting extends ConsumerWidget {
  const ReaderAppSetting(
      {super.key, required this.format, this.savePreference});
  final String format;
  final Future<void> Function(String, String)? savePreference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(readerPreferenceProvider(format));
    final readers = ref.watch(installedReadersProvider(format));
    final apps = readers.valueOrNull ?? [];
    final label = selected == 'internal'
        ? 'Openlib reader'
        : selected == 'ask'
            ? 'Ask every time'
            : apps
                    .where((app) => app.id == selected)
                    .map((app) => app.label)
                    .firstOrNull ??
                (readers.isLoading
                    ? 'Loading reader...'
                    : 'Reader unavailable');
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
      child: Material(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(5),
        child: ListTile(
          title: Text('Open ${format.toUpperCase()}s with'),
          subtitle: Text(label),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showDialog<void>(
              context: context,
              builder: (_) => _ReaderDialog(
                  format: format, savePreference: savePreference)),
        ),
      ),
    );
  }
}

class _ReaderDialog extends ConsumerStatefulWidget {
  const _ReaderDialog({required this.format, this.savePreference});
  final String format;
  final Future<void> Function(String, String)? savePreference;
  @override
  ConsumerState<_ReaderDialog> createState() => _ReaderDialogState();
}

class _ReaderDialogState extends ConsumerState<_ReaderDialog> {
  bool _saving = false;
  String? _error;

  Future<void> _select(String value) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final name = '${widget.format}ReaderApp';
      await (widget.savePreference?.call(name, value) ??
          MyLibraryDb.instance.savePreference(name, value));
      if (!mounted) return;
      ref.read(readerPreferenceProvider(widget.format).notifier).state = value;
      Navigator.pop(context);
    } catch (_) {
      if (mounted)
        setState(() {
          _saving = false;
          _error = 'Could not save the reader. Try again.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(readerPreferenceProvider(widget.format));
    final installed = ref.watch(installedReadersProvider(widget.format));
    final choices = [
      const ReaderApp(id: 'internal', label: 'Openlib reader'),
      const ReaderApp(id: 'ask', label: 'Ask every time'),
      ...?installed.valueOrNull,
    ];
    return PopScope(
        canPop: !_saving,
        child: AlertDialog(
          title: Text('Open ${widget.format.toUpperCase()}s with'),
          contentPadding: const EdgeInsets.only(top: 12, bottom: 12),
          content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (installed.isLoading) const LinearProgressIndicator(),
                  for (final choice in choices)
                    RadioListTile<String>(
                      title: Text(choice.label),
                      subtitle: choice.requiresImport
                          ? const Text(
                              'Import from Download/Openlib after opening Bookshelf.')
                          : null,
                      value: choice.id,
                      groupValue: selected,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: _saving ? null : (value) => _select(value!),
                    ),
                  if (installed.hasError)
                    const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                            'Could not list reading apps. Close this menu and try again.')),
                  if (_saving) const LinearProgressIndicator(),
                  if (_error != null)
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                ]),
              )),
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary),
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('Cancel'))
          ],
        ));
  }
}
