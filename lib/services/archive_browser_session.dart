import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:openlib/services/annas_archieve.dart';

/// Uses the same WebView cookie store as the visible website-check page.
class ArchiveBrowserSession {
  static Future<String> loadPage(String url) async {
    final result = Completer<String>();
    final browser = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        incognito: false,
      ),
      onLoadStop: (controller, currentUrl) async {
        if (result.isCompleted ||
            currentUrl == null ||
            !AnnasArchieve.matchesRequestedPage(url, currentUrl.toString()))
          return;
        try {
          final html = await controller.evaluateJavascript(
              source: 'document.documentElement.outerHTML');
          if (!result.isCompleted &&
              html is String &&
              AnnasArchieve.isArchivePage(html)) result.complete(html);
        } catch (_) {
          // A redirect can replace the document while it is being read.
        }
      },
      onReceivedError: (_, request, error) {
        if (request.isForMainFrame == true && !result.isCompleted) {
          result.completeError(ArchiveRequestException(url: url, cause: error));
        }
      },
    );
    try {
      await browser.run();
      return await result.future.timeout(const Duration(seconds: 20),
          onTimeout: () =>
              throw ArchiveRequestException(url: url, needsBrowser: true));
    } finally {
      await browser.dispose();
    }
  }
}
