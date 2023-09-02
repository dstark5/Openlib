import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:openlib/state/state.dart' show dbProvider, myLibraryProvider;

Future<String> get getAppDirectoryPath async {
  if (Platform.isAndroid) {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
    // // final path = '/storage/emulated/0/Openlib';
    // print(directory.path);
    // // File(directory.path).copySync(newPath);
    // return '/storage/emulated/0/Openlib';
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
    print(e);
  }
}

// Future<void> getStoragePermissionAndroid() async {
//   if (Platform.isAndroid) {
//     print("hi");
//     if (await Permission.storage.status.isGranted ||
//         await Permission.manageExternalStorage.status.isGranted) {
//     final storagePermission = await Permission.storage.request().isGranted;
//     final manageStoragePermission =
//         await Permission.manageExternalStorage.request().isGranted;
//     print(storagePermission || manageStoragePermission);
//     if (storagePermission || manageStoragePermission) {
//       await openAppSettings();
//       print(storagePermission || manageStoragePermission);
//     }
//   }
//   }
// }

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
    await ref.read(dbProvider).deleteBookState(fileName);
    // ignore: unused_result
    ref.refresh(myLibraryProvider);
  } catch (e) {
    // print(e);
    rethrow;
  }
}
