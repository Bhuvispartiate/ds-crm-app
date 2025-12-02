import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

// Conditional imports for web
import 'web_view_stub.dart'
    if (dart.library.html) 'web_view_web.dart' as web_impl;

// Import for mobile
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DS CRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool isOnline = true;
  Timer? _connectivityTimer;
  late WebViewController _mobileController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      web_impl.initializeWeb(
        onConnectivityChange: (online) {
          if (mounted) {
            setState(() {
              isOnline = online;
            });
          }
        },
      );
    } else {
      _initializeMobileWebView();
    }
  }

  void _initializeMobileWebView() {
    _mobileController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              isOnline = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              isOnline = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://ds-crm.web.app'));

    // Monitor connectivity for mobile
    _startConnectivityMonitoring();
  }

  void _startConnectivityMonitoring() {
    if (!kIsWeb) {
      _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        // Try to reload if offline
        if (!isOnline) {
          _mobileController.loadRequest(Uri.parse('https://ds-crm.web.app'));
        }
      });
    }
  }

  void _retryConnection() {
    if (kIsWeb) {
      // Web retry handled by web_impl
      web_impl.retryConnection();
    } else {
      // Mobile retry
      setState(() {
        _isLoading = true;
      });
      _mobileController.loadRequest(Uri.parse('https://ds-crm.web.app'));
    }
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: web_impl.buildWebView(isOnline),
      );
    } else {
      // Mobile view
      return Scaffold(
        body: Stack(
          children: [
            if (isOnline)
              WebViewWidget(controller: _mobileController)
            else
              _buildOfflineView(),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildOfflineView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 32),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Please check your internet connection and try again.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _retryConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF667eea),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'RETRY CONNECTION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
