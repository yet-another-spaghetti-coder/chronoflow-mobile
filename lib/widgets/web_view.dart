import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWithLoading extends StatefulWidget {
  final String url;
  final String cookie;
  const WebViewWithLoading({super.key, required this.url, required this.cookie});

  @override
  State<WebViewWithLoading> createState() => _WebViewWithLoadingState();
}

class _WebViewWithLoadingState extends State<WebViewWithLoading> {
  late final WebViewController controller;
  int loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    WebViewCookie authCookie = WebViewCookie(
      name: 'token',
      value: 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImMyN2JhNDBiMDk1MjlhZDRmMTY4MjJjZTgzMTY3YzFiYzM5MTAxMjIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI1MDQ0NTIyOTgwNi1tZnJ2anA2NDY1MmFjYTBoY2U5bm01MG1oM2hsZHBjdC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImF1ZCI6IjUwNDQ1MjI5ODA2LW1mcnZqcDY0NjUyYWNhMGhjZTlubTUwbWgzaGxkcGN0LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTE0MjI2Nzk4OTY2OTgzMTUzMjMyIiwiZW1haWwiOiJjaG93anNzQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoicm1pQUJoQWZBU3A3S0dKU2J3NXpjUSIsIm5vbmNlIjoiMjRDYTlOSzRCV3ZiU2d0LVZLWHFVOFh4S1hlbHYzWGtkQXF0VEFHYWM1cyIsIm5hbWUiOiJTaGlybGV5IENob3ciLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jS2RXcEp3UEUtWmszT2VxeFcyMFU0cGNBM0Y5allQQlV0YktadUNrTS1XN0ljcUxRPXM5Ni1jIiwiZ2l2ZW5fbmFtZSI6IlNoaXJsZXkiLCJmYW1pbHlfbmFtZSI6IkNob3ciLCJpYXQiOjE3NzA1MDY5NjYsImV4cCI6MTc3MDUxMDU2Nn0.EplAdbaoL8Lr0fcUvktJHxSGpRS4asa0Rh04OPdHIPvxZOg6hD6zf4KJ8d8HyDvjQfVeCTtlqjvWP9vbIP5W0YNTYCaTuK4fv_hqa4FWSGe2c1JX5gVN4k3RVsSv1j84BGNudYCu8wpFm6O6LSAZGMhuOhsXNbUBHsEnjgXNhMCXUiwxVny1mV44Hq5H_YFHO-yo6tMucdx6ZDDZzCCidqvA9bLTTUL5dZ59E4hhHDrpQWs2wIsmwI-Cf6fl6R6K90synC9gfr4URLT0dC99_nFpv-Y5KOL3GcTdyu3-S3inse7KtUsi4p0F2DsegFf5-s6kmh3byswu99yBKbLLEQ',
      path: '/',
      domain: "localhost",
    );
    final WebViewCookieManager cookieManager = WebViewCookieManager();
    cookieManager.setCookie(authCookie);
    
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: WebViewWidget(controller: controller)),
        if (loadingProgress < 100)
          Expanded(
            child: LinearProgressIndicator(value: loadingProgress / 100.0),
          ),
      ],
    );
  }
}
