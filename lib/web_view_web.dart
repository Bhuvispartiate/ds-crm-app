import 'package:flutter/widgets.dart';
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'dart:async';

const String _onlineViewID = 'ds-crm-iframe';
const String _offlineViewID = 'offline-iframe';
bool _isRegistered = false;
Timer? _connectivityTimer;
Function(bool)? _onConnectivityChange;

void initializeWeb({required Function(bool) onConnectivityChange}) {
  _onConnectivityChange = onConnectivityChange;
  _checkInitialConnectivity();
  _startConnectivityMonitoring();
  _setupEventListeners();
}

void _checkInitialConnectivity() {
  final isOnline = html.window.navigator.onLine ?? true;
  _registerViewFactories();
  _onConnectivityChange?.call(isOnline);
}

void _registerViewFactories() {
  if (_isRegistered) return;

  // Register online iframe view factory
  try {
    ui_web.platformViewRegistry.registerViewFactory(
      _onlineViewID,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'https://ds-crm.web.app'
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%';

        // Listen for iframe load errors
        iframe.onError.listen((event) {
          _onConnectivityChange?.call(false);
        });

        return iframe;
      },
    );
  } catch (e) {
    // View already registered
  }

  // Register offline iframe view factory
  try {
    ui_web.platformViewRegistry.registerViewFactory(
      _offlineViewID,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'offline.html'
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%';
        return iframe;
      },
    );
  } catch (e) {
    // View already registered
  }

  _isRegistered = true;
}

void _setupEventListeners() {
  // Listen for online event
  html.window.onOnline.listen((event) {
    _onConnectivityChange?.call(true);
  });

  // Listen for offline event
  html.window.onOffline.listen((event) {
    _onConnectivityChange?.call(false);
  });
}

void _startConnectivityMonitoring() {
  // Check connectivity every 10 seconds
  _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
    final currentStatus = html.window.navigator.onLine ?? true;
    _onConnectivityChange?.call(currentStatus);
  });
}

Widget buildWebView(bool isOnline) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 500),
    child: HtmlElementView(
      key: ValueKey(isOnline ? 'online' : 'offline'),
      viewType: isOnline ? _onlineViewID : _offlineViewID,
    ),
  );
}

void retryConnection() {
  final isOnline = html.window.navigator.onLine ?? true;
  _onConnectivityChange?.call(isOnline);
}
