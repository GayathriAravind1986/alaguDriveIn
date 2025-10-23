import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  bool isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  Timer? connectivityCheckTimer;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    listenToConnectivityChanges();
    startPeriodicCheck();
  }

  Future<void> checkInternetConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (!result.any((r) => r != ConnectivityResult.none)) {
        if (mounted) setState(() => isOnline = false);
        debugPrint('❌ No active network');
        return;
      }

      // Use a 204 lightweight endpoint (Google's Android check)
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 5));

      final connected = response.statusCode == 204;
      if (mounted) setState(() => isOnline = connected);

      debugPrint(connected
          ? '✅ Internet connection available'
          : '❌ Internet connection not reachable');
    } catch (e) {
      if (mounted) setState(() => isOnline = false);
      debugPrint('❌ Error checking connection: $e');
    }
  }

  void listenToConnectivityChanges() {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      debugPrint('🔄 Connectivity changed: $results');

      final hasConnection = results.any((r) => r != ConnectivityResult.none);

      if (hasConnection) {
        checkInternetConnection();
      } else {
        if (mounted) setState(() => isOnline = false);
      }
    });
  }

  void startPeriodicCheck() {
    connectivityCheckTimer = Timer.periodic(
        const Duration(seconds: 10), (_) => checkInternetConnection());
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    connectivityCheckTimer?.cancel();
    super.dispose();
  }
}

// Reusable status widget with animated indicator
class ConnectionStatusWidget extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onTap;

  const ConnectionStatusWidget({
    super.key,
    required this.isOnline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOnline ? Colors.green : Colors.red,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline ? Icons.cloud_done : Icons.cloud_off,
              size: 16,
              color: isOnline ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 6),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
