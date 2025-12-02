import 'package:flutter/widgets.dart';

// Stub implementation for non-web platforms
void initializeWeb({required Function(bool) onConnectivityChange}) {
  // No-op for non-web platforms
}

Widget buildWebView(bool isOnline) {
  return const SizedBox.shrink();
}

void retryConnection() {
  // No-op for non-web platforms
}
