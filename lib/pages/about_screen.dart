import 'package:chronoflow/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

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

  void _initializeWebView() {
    final targetUrl = Uri.parse('${Constants.chronoflowFrontend}${Constants.aboutPageUrl}');

    if (!_isAllowedUrl(targetUrl)) {
      setState(() {
        _errorMessage = 'Blocked: URL is not in the allowed domains list.';
        _isLoading = false;
      });
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);
            if (!_isAllowedUrl(uri)) {
              setState(() {
                _errorMessage = 'Blocked: navigation to ${uri.host} is not allowed.';
              });
              return NavigationDecision.prevent;
            }
            setState(() {
              _errorMessage = null;
              _isLoading = true;
            });
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            if (_isSslError(error)) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Connection blocked: insecure or invalid SSL certificate.';
              });
              return;
            }
            setState(() {
              _isLoading = false;
              _errorMessage = 'Failed to load page: ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(targetUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(),
        elevation: 2,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Center(
                child: Column(
                  children: [
                    const FlutterLogo(size: 100),
                    Text(Constants.sidebarTitle),
                  ],
                ),
              ),
            ),
            ListTile(
              hoverColor: Colors.white,
              leading: const Icon(Icons.event),
              title: const Text('EVENTS'),
              onTap: () => Navigator.pushReplacementNamed(context, Constants.eventsScreen),
            ),
            ListTile(
              hoverColor: Colors.white,
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('CHECK IN'),
              onTap: () => Navigator.pushReplacementNamed(context, Constants.checkInScreen),
            ),
            ListTile(
              hoverColor: Colors.white,
              leading: const Icon(Icons.info),
              title: const Text('ABOUT'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              hoverColor: Colors.white,
              leading: const Icon(Icons.logout),
              title: const Text('LOGOUT'),
              onTap: () {
                Navigator.pop(context);
                // Sign out logic will be handled by parent
              },
            ),
          ],
        ),
      ),
      body: _errorMessage != null
          ? _buildErrorWidget()
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }

  Widget _buildErrorWidget() {
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
                _errorMessage!,
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
}
