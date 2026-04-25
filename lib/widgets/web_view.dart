import 'package:chronoflow/core/constants.dart';
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
  String? errorMessage;

  static const List<String> _allowedDomains = [
    'chronoflow.site',
    'www.chronoflow.site',
  ];

  bool _isAllowedUrl(Uri uri) {
    if (uri.scheme != 'https') {
      return false;
    }
    return _allowedDomains.any((domain) => uri.host == domain || uri.host.endsWith('.$domain'));
  }

  bool _isSslError(WebResourceError error) {
    if (error.errorType == WebResourceErrorType.failedSslHandshake) {
      return true;
    }
    // Android SSL error codes (-201 to -206)
    final androidSslCodes = [-201, -202, -203, -204, -205, -206];
    // iOS SSL error codes (-1201 to -1206)
    final iosSslCodes = [-1201, -1202, -1203, -1205, -1206];
    return androidSslCodes.contains(error.errorCode) || iosSslCodes.contains(error.errorCode);
  }

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    final targetUrl = Uri.parse(widget.url);

    if (!_isAllowedUrl(targetUrl)) {
      setState(() {
        errorMessage = 'Blocked: URL is not in the allowed domains list.';
        isInitialized = true;
      });
      return;
    }

    final cookie = await widget.fetchCookie();
    debugPrint('Cookie: $cookie');
    if (cookie != null) {
      final authCookie = WebViewCookie(
        name: 'token',
        value: cookie,
        domain: Constants.chronoflowDomain,
      );

      final cookieManager = WebViewCookieManager();
      await cookieManager.setCookie(authCookie);
      controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);
            if (!_isAllowedUrl(uri)) {
              setState(() {
                errorMessage = 'Blocked: navigation to ${uri.host} is not allowed.';
              });
              return NavigationDecision.prevent;
            }
            setState(() {
              errorMessage = null;
            });
            return NavigationDecision.navigate;
          },
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
          onWebResourceError: (error) {
            if (_isSslError(error)) {
              setState(() {
                errorMessage = 'Connection blocked: insecure or invalid SSL certificate.';
              });
              return;
            }
            setState(() {
              errorMessage = 'Failed to load page: ${error.description}';
            });
          },
        ),
      );
      await controller.loadRequest(targetUrl);

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

    if (errorMessage != null) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block, color: Colors.red.shade800, size: 48),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(child: WebViewWidget(controller: controller)),
        if (loadingProgress < 100) LinearProgressIndicator(value: loadingProgress / 100.0),
      ],
    );
  }
}
