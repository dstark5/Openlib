import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

class ReaderApp {
  const ReaderApp(
      {required this.id, required this.label, this.requiresImport = false});
  final String id;
  final String label;
  final bool requiresImport;
}

class ReaderApps {
  const ReaderApps();
  static const _channel = MethodChannel('openlib/readers');

  static String mimeType(String format) =>
      format == 'pdf' ? 'application/pdf' : 'application/epub+zip';

  Future<List<ReaderApp>> installedReaders(String format) async {
    try {
      final values = await _channel
          .invokeListMethod<dynamic>('readers', {'mimeType': mimeType(format)});
      return (values ?? [])
          .map((value) => ReaderApp(
                id: value['id'] as String,
                label: value['label'] as String,
                requiresImport: value['requiresImport'] == true,
              ))
          .toList();
    } on MissingPluginException {
      return [];
    }
  }

  Future<void> openBook(
      {required String path,
      required String format,
      required String reader,
      String? title}) async {
    final name = title == null || title.trim().isEmpty
        ? path.split('/').last
        : '${title.trim().replaceAll(RegExp(r'[/\\]'), '_')}.$format';
    try {
      await _channel.invokeMethod<void>('open', {
        'path': path,
        'mimeType': mimeType(format),
        'reader': reader,
        'displayName': name,
      });
    } on MissingPluginException {
      final result = await OpenFile.open(path,
          type: mimeType(format), linuxByProcess: true);
      if (result.type != ResultType.done) {
        throw PlatformException(
            code: 'reader_unavailable', message: result.message);
      }
    }
  }
}
