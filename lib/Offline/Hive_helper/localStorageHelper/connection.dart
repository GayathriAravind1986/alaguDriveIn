import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service.dart';

void initConnectivityListener(ApiProvider apiProvider) {
  Connectivity().onConnectivityChanged.listen((result) {
    if (result != ConnectivityResult.none) {
      print("✅ Back online → syncing pending orders...");
      HiveService.syncPendingOrders(apiProvider);
    }
  });
}