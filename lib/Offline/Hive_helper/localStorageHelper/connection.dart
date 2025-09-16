import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/Stock/hive_serive_stock.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service.dart';

/// Initialize connectivity listener
/// Handles both mobile and web (including legacy web that emits List<dynamic>)
void initConnectivityListener(ApiProvider apiProvider) {
  Connectivity().onConnectivityChanged.listen((dynamic result) {
    ConnectivityResult? status;

    if (result is ConnectivityResult) {
      // ✅ Normal case: mobile + newer web
      status = result;
    } else if (kIsWeb && result is List && result.isNotEmpty) {
      // ✅ Legacy web case: returns a JSArray<dynamic>
      final first = result.first;
      if (first is ConnectivityResult) {
        status = first;
      }
    }

    final isConnected = status != null && status != ConnectivityResult.none;

    if (isConnected) {
      print("✅ Back online → syncing pending orders & stock...");
      HiveService.syncPendingOrders(apiProvider);
      // HiveStockService.syncPendingStock();
    } else {
      print("📴 Offline mode detected");
    }
  });
}
