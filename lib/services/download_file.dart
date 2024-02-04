import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:chunked_downloader/chunked_downloader.dart';
import 'files.dart';

Future<String> _getFilePath(String fileName) async {
  final path = await getAppDirectoryPath;
  return '$path/$fileName';
}

List<String> _reorderMirrors(List<String> mirrors) {
  List<String> ipfsMirrors = [];
  List<String> httpsMirrors = [];

  for (var element in mirrors) {
    if (element.contains('ipfs') == true) {
      ipfsMirrors.add(element);
    } else {
      if (element.startsWith('https://annas-archive.org') != true &&
          element.startsWith('https://1lib.sk') != true) {
        httpsMirrors.add(element);
      }
    }
  }
  return [...ipfsMirrors, ...httpsMirrors];
}

Future<String?> _getAliveMirror(List<String> mirrors, Dio dio) async {
  for (var url in mirrors) {
    try {
      final response = await dio.head(url,
          options: Options(receiveTimeout: const Duration(seconds: 10)));
      if (response.statusCode == 200) {
        dio.close();
        return url;
      }
    } catch (_) {
      // print("timeOut");
    }
  }
  return null;
}

Future<void> downloadFile(
    {required List<String> mirrors,
    required String md5,
    required String format,
    required Function onStart,
    required Function onProgress,
    required Function cancelDownlaod,
    required Function mirrorStatus,
    required Function onDownlaodFailed}) async {
  Dio dio = Dio();

  String path = await _getFilePath('$md5.$format');
  List<String> orderedMirrors = _reorderMirrors(mirrors);

  String? workingMirror = await _getAliveMirror(orderedMirrors, dio);

  // print(workingMirror);
  // print(path);
  // print(orderedMirrors);
  // print(orderedMirrors[0]);

  if (workingMirror != null) {
    onStart();
    try {
      var chunkedDownloader = await ChunkedDownloader(
              url: workingMirror,
              saveFilePath: path,
              chunkSize: 32 * 1024,
              onError: (error) {
                onDownlaodFailed();
              },
              onProgress: (received, total, speed) {
                onProgress(received, total);
              },
              onDone: (file) {})
          .start();

      mirrorStatus(true);
      cancelDownlaod(chunkedDownloader);
    } catch (_) {
      onDownlaodFailed();
    }
  } else {
    onDownlaodFailed();
  }
}

Future<bool> verifyFileCheckSum(
    {required String md5Hash, required String format}) async {
  try {
    final path = await getAppDirectoryPath;
    final filePath = '$path/$md5Hash.$format';
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
