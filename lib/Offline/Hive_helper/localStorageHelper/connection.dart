import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service.dart';

void initConnectivityListener(ApiProvider apiProvider) {
  Connectivity().onConnectivityChanged.listen((result) {
    bool isConnected = false;

    if (kIsWeb && result is List) {
      // Web sometimes gives List<dynamic>
      final first = result.isNotEmpty ? result.first : null;
      isConnected = first != null && first != ConnectivityResult.none;
    } else if (result is ConnectivityResult) {
      // Mobile & newer web
      isConnected = result != ConnectivityResult.none;
    }

    if (isConnected) {
      print("✅ Back online → syncing pending orders...");
      HiveService.syncPendingOrders(apiProvider);
    } else {
      print("📴 Offline mode detected");
    }
  });
}
