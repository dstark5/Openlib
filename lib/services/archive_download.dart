import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart' show parse;
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/download_file.dart';

List<String> archiveDownloadLinks(String html, String pageUrl) {
  final document = parse(html);
  final direct = document.querySelectorAll('p.mb-4.text-xl.font-bold a[href]');
  final anchors = Uri.parse(pageUrl).path.startsWith('/slow_download/')
      ? direct
      : document.querySelectorAll('ul > li > a[href]');
  final urls = anchors
      .map((a) => Uri.parse(pageUrl).resolve(a.attributes['href']!).toString())
      .where((url) => Uri.tryParse(url)?.scheme == 'https')
      .toSet()
      .toList();
  return orderDownloadMirrors(urls, archiveBaseUrl: Uri.parse(pageUrl).origin);
}

class ArchiveDownload {
  static Future<List<String>> resolve(String url) async {
    final result = Completer<List<String>>();
    InAppWebViewController? controller;
    bool reading = false;
    Future<void> inspect() async {
      if (reading || controller == null || result.isCompleted) return;
      reading = true;
      try {
        final current = await controller!.getUrl();
        if (current == null ||
            !AnnasArchieve.matchesRequestedPage(url, current.toString()))
          return;
        final html = await controller!
            .evaluateJavascript(source: 'document.documentElement.outerHTML');
        if (html is String) {
          final links = archiveDownloadLinks(html, current.toString());
          if (links.isNotEmpty && !result.isCompleted) result.complete(links);
        }
      } catch (_) {/* The document may be redirecting. */} finally {
        reading = false;
      }
    }

    final browser = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      onWebViewCreated: (value) => controller = value,
      onLoadStop: (_, __) => inspect(),
    );
    final poll = Timer.periodic(const Duration(seconds: 1), (_) => inspect());
    try {
      await browser.run();
      return await result.future.timeout(const Duration(seconds: 15),
          onTimeout: () =>
              throw ArchiveRequestException(url: url, needsBrowser: true));
    } finally {
      poll.cancel();
      await browser.dispose();
    }
  }
}
