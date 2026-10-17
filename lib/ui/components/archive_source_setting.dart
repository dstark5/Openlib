import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/state/state.dart';

class ArchiveSourceSetting extends ConsumerWidget {
  const ArchiveSourceSetting({super.key, this.savePreference});

  final Future<void> Function(String)? savePreference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(archiveBaseUrlProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
      child: Material(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(5),
        child: ListTile(
          title: const Text("Anna's Archive website"),
          subtitle: Text(Uri.parse(url).host),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => _ArchiveSourceDialog(
              initialUrl: url,
              save: (value) async {
                await (savePreference?.call(value) ??
                    MyLibraryDb.instance
                        .savePreference('annasArchiveBaseUrl', value));
                ref.read(archiveBrowserPagesProvider.notifier).state = {};
                ref.read(archiveBaseUrlProvider.notifier).state = value;
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchiveSourceDialog extends StatefulWidget {
  const _ArchiveSourceDialog({required this.initialUrl, required this.save});
  final String initialUrl;
  final Future<void> Function(String) save;

  @override
  State<_ArchiveSourceDialog> createState() => _ArchiveSourceDialogState();
}

class _ArchiveSourceDialogState extends State<_ArchiveSourceDialog> {
  final _form = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initialUrl);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.save(AnnasArchieve.normalizeBaseUrl(_controller.text));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save the website. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: const Text("Anna's Archive website"),
        content: SingleChildScrollView(
            child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
                'Use the HTTPS address of the Anna\'s Archive website that opens on your phone.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              enabled: !_saving,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                  labelText: 'Website address',
                  errorMaxLines: 3,
                  hintText: AnnasArchieve.defaultBaseUrl),
              validator: (value) {
                try {
                  AnnasArchieve.normalizeBaseUrl(value ?? '');
                  return null;
                } on FormatException {
                  return 'Enter an HTTPS website address without a path.';
                }
              },
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ]),
        )),
        actions: [
          TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary),
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary),
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save')),
        ],
      ),
    );
  }
}
