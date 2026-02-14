import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWithLoading extends StatefulWidget {
  final String url;
  final Future<String?> Function() fetchCookie;
  const WebViewWithLoading({
    required this.url,
    required this.fetchCookie,
    super.key,
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
    final cookie = await widget.fetchCookie();
    if (cookie != null) {
      final authCookie = WebViewCookie(
        name: 'token',
        value: cookie,
        domain: 'localhost',
      );

      final cookieManager = WebViewCookieManager();
      await cookieManager.setCookie(authCookie); // Wait for cookie to be set
      // Then initialize the controller
      controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              loadingProgress = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              loadingProgress = 100;
            });
          },
        ),
      );
      await controller.loadRequest(Uri.parse(widget.url));

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
        if (loadingProgress < 100) LinearProgressIndicator(value: loadingProgress / 100.0),
      ],
    );
  }
}
