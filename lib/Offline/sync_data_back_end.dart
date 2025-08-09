// lib/Offline/sync_data_back_end.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

Future<void> syncDataWithBackend() async {
  try {
    debugPrint("Syncing data with backend...");

    // 1️⃣ Get pending offline data from Hive/local DB
    // Example:
    // var box = await Hive.openBox<Map>('pending_actions');
    // for (var action in box.values) {
    //   await sendActionToApi(action); // Implement this
    //   await box.delete(action.key);
    // }

    // 2️⃣ Optionally refresh data from API and update local cache

    debugPrint("Sync completed successfully.");
  } catch (e) {
    debugPrint("Error while syncing: $e");
  }
}

Future<void> addPendingAction(Map<String, dynamic> action) async {
  var box = await Hive.openBox<Map>('pending_actions');
  await box.add(action);
}
