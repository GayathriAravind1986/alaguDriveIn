import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService
{
  static final ConnectivityService _instance = ConnectivityService._internal();
  ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // Handle both single result and list of results
      if (connectivityResult is List<ConnectivityResult>) {
        return connectivityResult.any((result) => result != ConnectivityResult.none);
      } else if (connectivityResult is ConnectivityResult) {
        return connectivityResult != ConnectivityResult.none;
      } else if (kIsWeb && connectivityResult is List) {
        // Handle web legacy case
        return connectivityResult.isNotEmpty &&
            connectivityResult.any((result) => result != ConnectivityResult.none);
      }

      return false;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  Stream<dynamic> get onConnectivityChanged => Connectivity().onConnectivityChanged;
}
