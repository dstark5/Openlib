import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:openlib/state/state.dart' show dbProvider, myLibraryProvider;

Future<String> get getAppDirectoryPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
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
  String appDirPath = await getAppDirectoryPath;
  String filePath = '$appDirPath/$fileName';
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
    String appDirPath = await getAppDirectoryPath;
    await deleteFile('$appDirPath/$fileName');
    await ref.read(dbProvider).delete(md5);
    // ignore: unused_result
    ref.refresh(myLibraryProvider);
  } catch (e) {
    print(e);
  }
}
