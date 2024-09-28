// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Webview extends ConsumerStatefulWidget {
  const Webview({super.key, required this.url});
  final String url;
  @override
  // ignore: library_private_types_in_public_api
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends ConsumerState<Webview> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Solve Captcha"),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {},
                    onLoadStop: (controller, url) async {
                      String query =
                          """var paragraphTag=document.querySelector('p[class="mb-4 text-xl font-bold"]');var anchorTagHref=paragraphTag.querySelector('a').href;var url=()=>{return anchorTagHref};url();""";
                      String? mirrorLink = await webViewController
                          ?.evaluateJavascript(source: query);
                      // final ipfsUrl = widget.url
                      //     .replaceAll("slow_download", "ipfs_downloads")
                      //     .replaceAll("/0/2", "");

                      // await webViewController?.loadUrl(
                      //     urlRequest: URLRequest(
                      //         url: WebUri('https://example.com/new-page')));
                      if (mirrorLink != null) {
                        Future.delayed(const Duration(milliseconds: 70), () {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context, mirrorLink);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
