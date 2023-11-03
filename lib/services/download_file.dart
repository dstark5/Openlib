import 'package:dio/dio.dart';
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
          options: Options(receiveTimeout: const Duration(seconds: 5)));
      if (response.statusCode == 200) {
        return url;
      }
    } catch (e) {
      // print("timeOut");
    }
  }
  return null;
}

Future<void> downloadFile(
    {required List<String> mirrors,
    required String md5,
    required String format,
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
    try {
      CancelToken cancelToken = CancelToken();

      dio.download(
        workingMirror,
        path,
        options: Options(headers: {
          'Connection': 'Keep-Alive',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36'
        }),
        onReceiveProgress: (rcv, total) {
          onProgress(rcv, total);
        },
        deleteOnError: true,
        cancelToken: cancelToken,
      ).catchError((err) {
        if (err.type != DioExceptionType.cancel) {
          onDownlaodFailed();
        }
        throw err;
      });

      mirrorStatus(true);

      cancelDownlaod(cancelToken);
    } catch (e) {
      onDownlaodFailed();
    }
  } else {
    onDownlaodFailed();
  }
}
