// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:openlib/services/database.dart';
import 'package:openlib/state/state.dart' show myLibraryProvider;

MyLibraryDb dataBase = MyLibraryDb.instance;

Future<String> get getBookStorageDefaultDirectory async {
  if (Platform.isAndroid) {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  } else {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

Future<void> moveFilesToAndroidInternalStorage() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final directoryExternal = await getExternalStorageDirectory();
    List<FileSystemEntity> files = Directory(directory.path).listSync();
    for (var element in files) {
      if ((element.path.contains('pdf')) || element.path.contains('epub')) {
        String fileName = element.path.split('/').last;
        File file = File(element.path);
        file.copySync('${directoryExternal!.path}/$fileName');
        file.deleteSync();
      }
    }
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }
}

Future<void> moveFolderContents(
    String source_path, String destination_path) async {
  final source = Directory(source_path);
  source.listSync(recursive: false).forEach((var entity) {
    if (entity is Directory) {
      var newDirectory =
          Directory('${destination_path}/${entity.path.split('/').last}');
      newDirectory.createSync();
      moveFolderContents(entity.path, newDirectory.path);
      entity.deleteSync();
    } else if (entity is File) {
      entity.copySync('${destination_path}/${entity.path.split('/').last}');
      entity.deleteSync();
    }
  });
}

Future<bool> isFileExists(String filePath) async {
  return await File(filePath).exists();
}

Future<void> deleteFile(String filePath) async {
  if (await isFileExists(filePath) == true) {
    await File(filePath).delete();
  }
}

Future<String> getFilePath(String fileName) async {
  final bookStorageDirectory =
      await dataBase.getPreference('bookStorageDirectory');
  String filePath = '$bookStorageDirectory/$fileName';
  bool isExists = await isFileExists(filePath);
  if (isExists == true) {
    return filePath;
  }
  throw "File Not Exists";
}

Future<void> deleteFileWithDbData(
    FutureProviderRef ref, String md5, String format) async {
  try {
    String fileName = '$md5.$format';
    final bookStorageDirectory =
        await dataBase.getPreference('bookStorageDirectory');
    await deleteFile('$bookStorageDirectory/$fileName');
    await dataBase.delete(md5);
    await dataBase.deleteBookState(fileName);
    // ignore: unused_result
    ref.refresh(myLibraryProvider);
  } catch (e) {
    // print(e);
    rethrow;
  }
}
