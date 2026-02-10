import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWithLoading extends StatefulWidget {
  final String url;
  final Future<String?> Function()fetchCookie;
  const WebViewWithLoading({
    super.key,
    required this.url,
    required this.fetchCookie,
  });

  @override
  State<WebViewWithLoading> createState() => _WebViewWithLoadingState();
}

class _WebViewWithLoadingState extends State<WebViewWithLoading> {
  late final WebViewController controller;
  int loadingProgress = 0;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    // Set up the cookie first
    String? cookie = await widget.fetchCookie();
    if (cookie != null) {
      WebViewCookie authCookie = WebViewCookie(
        name: 'token',
        value: cookie,
        path: '/',
        domain: "localhost",
      );

      final WebViewCookieManager cookieManager = WebViewCookieManager();
      await cookieManager.setCookie(authCookie); // Wait for cookie to be set
      // Then initialize the controller
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() {
                loadingProgress = progress;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                loadingProgress = 100;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));

      setState(() {
        isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(child: WebViewWidget(controller: controller)),
        if (loadingProgress < 100)
          LinearProgressIndicator(value: loadingProgress / 100.0),
      ],
    );
  }
}
