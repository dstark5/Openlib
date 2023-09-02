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
      if (element.startsWith('https://annas-archive.gs') != true) {
        httpsMirrors.add(element);
      }
    }
  }
  return [...ipfsMirrors, ...httpsMirrors];
}

Future<void> downloadFile(
    {required List<String> mirrors,
    required String md5,
    required String format,
    required Function onProgress,
    required Function cancelDownlaod,
    required Function onDownlaodFailed}) async {
  Dio dio = Dio();
  String path = await _getFilePath('$md5.$format');
  List<String> orderedMirrors = _reorderMirrors(mirrors);

  // print(path);
  // print(orderedMirrors);

  try {
    CancelToken cancelToken = CancelToken();

    dio.download(
      orderedMirrors[0],
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

    cancelDownlaod(cancelToken);
  } catch (e) {
    onDownlaodFailed();
  }
}
