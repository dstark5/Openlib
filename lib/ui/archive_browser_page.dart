import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:openlib/services/annas_archieve.dart';

class ArchiveBrowserPage extends StatefulWidget {
  const ArchiveBrowserPage({super.key, required this.url});
  final String url;

  @override
  State<ArchiveBrowserPage> createState() => _ArchiveBrowserPageState();
}

class _ArchiveBrowserPageState extends State<ArchiveBrowserPage> {
  InAppWebViewController? _controller;
  double _progress = 0;
  bool _reading = false;

  Future<void> _usePage() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _reading = true);
    try {
      final current = await controller.getUrl();
      final html = await controller.evaluateJavascript(
          source: 'document.documentElement.outerHTML');
      if (!mounted) return;
      if (current == null ||
          !AnnasArchieve.matchesRequestedPage(widget.url, current.toString()) ||
          html is! String ||
          !AnnasArchieve.isArchivePage(html)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Finish the website check and wait for the requested page, then try again.'),
        ));
        return;
      }
      Navigator.pop(context, html);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not read this page. Reload it and try again.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(Uri.parse(widget.url).host),
          actions: [
            IconButton(
                tooltip: 'Reload page',
                icon: const Icon(Icons.refresh),
                onPressed: () => _controller?.reload())
          ],
        ),
        body: SafeArea(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Complete any website check below. When the book page or search results appear, tap Use this page.',
                style: Theme.of(context).textTheme.bodyMedium,
              )),
          if (_progress < 1) LinearProgressIndicator(value: _progress),
          Expanded(
              child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onWebViewCreated: (controller) =>
                setState(() => _controller = controller),
            onProgressChanged: (_, progress) {
              if (mounted) setState(() => _progress = progress / 100);
            },
          )),
          Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary),
                    onPressed:
                        _reading || _controller == null ? null : _usePage,
                    child:
                        Text(_reading ? 'Reading page...' : 'Use this page')),
              )),
        ])),
      );
}
