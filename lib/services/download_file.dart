// Dart imports:
import 'dart:io';
import 'dart:async';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

// Project imports:
import 'package:openlib/services/database.dart' show MyLibraryDb;
import 'package:openlib/services/annas_archieve.dart';

MyLibraryDb dataBase = MyLibraryDb.instance;

Future<String> _getFilePath(String fileName) async {
  String bookStorageDirectory =
      await dataBase.getPreference('bookStorageDirectory');
  return '$bookStorageDirectory/$fileName';
}

List<String> orderDownloadMirrors(List<String> mirrors,
    {String archiveBaseUrl = AnnasArchieve.defaultBaseUrl}) {
  List<String> ipfsMirrors = [];
  List<String> httpsMirrors = [];

  for (var element in mirrors) {
    if (element.contains('ipfs') == true) {
      ipfsMirrors.add(element);
    } else {
      final host = Uri.tryParse(element)?.host;
      if (host != Uri.parse(archiveBaseUrl).host &&
          host != '1lib.sk' &&
          !(host?.startsWith('annas-archive.') ?? false)) {
        httpsMirrors.add(element);
      }
    }
  }
  return [...ipfsMirrors, ...httpsMirrors];
}

Future<String?> selectDownloadMirror(List<String> mirrors, {Dio? dio}) async {
  if (mirrors.isEmpty) return null;
  if (mirrors.length == 1) return mirrors.single;
  final client = dio ??
      Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5)));
  final result = Completer<String?>();
  var remaining = mirrors.length;
  for (final url in mirrors) {
    () async {
      try {
        final response = await client.head(url);
        if (response.statusCode == 200 && !result.isCompleted)
          result.complete(url);
      } catch (_) {
        // Other mirrors can still succeed.
      } finally {
        if (--remaining == 0 && !result.isCompleted) result.complete(null);
      }
    }();
  }
  try {
    return await result.future;
  } finally {
    if (dio == null) client.close(force: true);
  }
}

Future<void> downloadFile(
    {required List<String> mirrors,
    String archiveBaseUrl = AnnasArchieve.defaultBaseUrl,
    required String md5,
    required String format,
    required void Function(int, int) onProgress,
    required CancelToken cancelToken}) async {
  final ordered = orderDownloadMirrors(mirrors, archiveBaseUrl: archiveBaseUrl);
  if (ordered.isEmpty) throw StateError('No download mirrors available.');
  final preferred = await selectDownloadMirror(ordered);
  if (cancelToken.isCancelled) throw cancelToken.cancelError!;
  final candidates = [
    if (preferred != null) preferred,
    ...ordered.where((url) => url != preferred)
  ];
  final path = await _getFilePath('$md5.$format');
  final client = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 25)));
  try {
    for (final url in candidates) {
      try {
        await client.download(url, path,
            cancelToken: cancelToken,
            deleteOnError: true,
            onReceiveProgress: onProgress);
        return;
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) rethrow;
      }
    }
    throw StateError('No working download mirrors.');
  } finally {
    client.close(force: true);
  }
}

Future<bool> verifyFileCheckSum(
    {required String md5Hash, required String format}) async {
  try {
    final bookStorageDirectory =
        await dataBase.getPreference('bookStorageDirectory');
    final filePath = '$bookStorageDirectory/$md5Hash.$format';
    final file = File(filePath);
    final stream = file.openRead();
    final hash = await md5.bind(stream).first;
    if (md5Hash == hash.toString()) {
      return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}
