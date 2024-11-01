import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareBook(String title, String link, String path) async {
  try {
    String imagePath = await saveAndGetImagePath(path);
    String message = 'Discover this amazing book: "$title"\nRead more : $link';
    if (imagePath.isNotEmpty) {
      await Share.shareXFiles([XFile(imagePath)], text: message);
    } else {
      await Share.share(message);
    }
  } catch (e) {
    debugPrint('Error sharing the book: $e');
  }
}

Future<String> saveAndGetImagePath(String url) async {
  if (url != null && url.isNotEmpty) {
    try {
      final imageProvider = CachedNetworkImageProvider(url);
      final imageStream = imageProvider.resolve(const ImageConfiguration());
      String? localFilePath;

      final Completer<ByteData> completer = Completer();

      imageStream.addListener(
        ImageStreamListener(
          (ImageInfo info, bool _) async {
            try {
              final ByteData? byteData =
                  await info.image.toByteData(format: ImageByteFormat.png);
              if (byteData != null) {
                final Uint8List imageBytes = byteData.buffer.asUint8List();
                final Directory tempDir = await getTemporaryDirectory();
                final File imageFile = File('${tempDir.path}/image.jpg');

                await imageFile.writeAsBytes(imageBytes);
                localFilePath = imageFile.path;
                completer.complete(byteData);
              } else {
                completer.completeError('Failed to get image bytes');
              }
            } catch (e) {
              completer.completeError(e);
            }
          },
          onError: (exception, stackTrace) {
            completer.completeError('Failed to get image bytes');
          },
        ),
      );
      await completer.future;
      return localFilePath ?? "";
    } catch (e) {
      return "";
    }
  } else {
    return "";
  }
}
