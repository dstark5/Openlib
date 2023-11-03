import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart'
    as cookiejar;

import 'package:openlib/state/state.dart'
    show cookieProvider, userAgentProvider, dbProvider, bookInfoProvider;

class Webview extends ConsumerStatefulWidget {
  const Webview({Key? key, required this.url}) : super(key: key);
  final String url;
  @override
  // ignore: library_private_types_in_public_api
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends ConsumerState<Webview> {
  WebViewController controller = WebViewController();

  final cookieManager = cookiejar.WebviewCookieManager();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Solve Captcha"),
      ),
      body: SafeArea(
        child: WebViewWidget(
          controller: controller
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..loadRequest(Uri.parse(widget.url))
            ..getUserAgent().then((value) {
              ref.read(userAgentProvider.notifier).state = value!;
              ref.read(dbProvider).setBrowserOptions('userAgent', value);
            })
            ..setNavigationDelegate(NavigationDelegate(
              onPageStarted: (url) async {
                var urlStatusCode = await controller.runJavaScriptReturningResult(
                    "var xhr = new XMLHttpRequest();xhr.open('GET', window.location.href, false);xhr.send(null);xhr.status;");

                if (urlStatusCode.toString().contains('200')) {
                  final cookies = await cookieManager
                      .getCookies("https://annas-archive.org");

                  List<String> cookie = [];
                  for (var element in cookies) {
                    if (element.name == 'cf_clearance' ||
                        element.name == 'cf_chl_2') {
                      cookie.add(element.toString().split(';')[0]);
                    }
                  }

                  String cfClearance = cookie.join('; ');

                  ref.read(cookieProvider.notifier).state = cfClearance;

                  await ref
                      .read(dbProvider)
                      .setBrowserOptions('cookie', cfClearance);

                  ref.invalidate(bookInfoProvider);

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
            )),
        ),
      ),
    );
  }
}
