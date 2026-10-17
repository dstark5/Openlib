import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:openlib/services/archive_download.dart';

class Webview extends StatefulWidget {
  const Webview({super.key, required this.url});
  final String url;
  @override
  State<Webview> createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  InAppWebViewController? _controller;
  Timer? _poll;
  bool _reading = false;
  bool _finished = false;
  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 1), (_) => _inspect());
  }

  void _finish(List<String> links) {
    if (!mounted || _finished || links.isEmpty) return;
    _finished = true;
    Navigator.pop(context, links);
  }

  Future<void> _inspect() async {
    if (_controller == null || _reading || _finished) return;
    _reading = true;
    try {
      final html = await _controller!
          .evaluateJavascript(source: 'document.documentElement.outerHTML');
      final url = await _controller!.getUrl();
      if (html is String && url != null)
        _finish(archiveDownloadLinks(html, url.toString()));
    } catch (_) {/* A website redirect can replace the document. */} finally {
      _reading = false;
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Download website')),
        body: SafeArea(
            child: Column(children: [
          const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  'Complete any website check. The download continues when the link is ready.')),
          Expanded(
              child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onWebViewCreated: (controller) => _controller = controller,
            onLoadStop: (_, __) => _inspect(),
            onDownloadStartRequest: (_, request) async =>
                _finish([request.url.toString()]),
          )),
        ])),
      );
}
