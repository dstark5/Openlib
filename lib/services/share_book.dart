import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

Future<void> shareBook(String title, String link, String path) async {
  try {
    final url = Uri.parse(path);
    final response = await http.get(url);
    final bytes = response.bodyBytes;

    //temp
    final temp = await getTemporaryDirectory();
    final dest = '${temp.path}/image.jpg';
    File(dest).writeAsBytes(bytes);

    String message = 'Discover this amazing book: "$title"\nRead more : $link';
    await Share.shareXFiles([XFile(dest)], text: message);
  } catch (e) {
    debugPrint('Error sharing the book: $e');
  }
}
