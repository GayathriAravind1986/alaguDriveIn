import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Order/hive_pending_delete.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_sync_service.dart';

class HiveServicedelete {
  static const String pendingDeleteBoxName = 'pending_deletes';
  static Box<PendingDelete>? _pendingDeleteBox;

  // Initialize the delete box (call this in your main.dart after existing Hive.initFlutter())
  static Future<void> initDeleteBox() async {
    try {
      // if (!Hive.isAdapterRegistered(1)) {
      //   Hive.registerAdapter(PendingDeleteAdapter());
      // }
      _pendingDeleteBox = await Hive.openBox<PendingDelete>(pendingDeleteBoxName);
      print('✅ Delete box initialized successfully');
    } catch (e) {
      print('❌ Error initializing delete box: $e');
    }
  }

  static Box<PendingDelete> get pendingDeleteBox {
    if (_pendingDeleteBox == null) {
      throw Exception('Delete box not initialized. Call HiveService.initDeleteBox() first.');
    }
    return _pendingDeleteBox!;
  }

  // 🔧 IMPROVED: Add pending delete operation with duplicate check
  static Future<bool> addPendingDelete(String orderId) async {
    try {
      if (_pendingDeleteBox == null) {
        await initDeleteBox();
      }

      // Check if there's already a pending delete for this order
      final existing = pendingDeleteBox.values
          .where((item) => item.orderId == orderId && item.status == 'pending')
          .isNotEmpty;

      if (existing) {
        print('⚠️ Pending delete already exists for order: $orderId');
        return false; // Already exists
      }

      final pendingDelete = PendingDelete(
        orderId: orderId,
        timestamp: DateTime.now(),
        status: 'pending',
      );

      await pendingDeleteBox.add(pendingDelete);
      print('✅ Added pending delete for order: $orderId');
      return true; // Successfully added

    } catch (e) {
      print('❌ Error adding pending delete: $e');
      return false;
    }
  }

  // 🔧 IMPROVED: Check if order is already pending deletion
  static bool isPendingDelete(String orderId) {
    try {
      if (_pendingDeleteBox == null) return false;

      return pendingDeleteBox.values
          .where((item) => item.orderId == orderId && item.status == 'pending')
          .isNotEmpty;
    } catch (e) {
      print('❌ Error checking pending delete: $e');
      return false;
    }
  }

  // Get all pending deletes
  static List<PendingDelete> getPendingDeletes() {
    try {
      if (_pendingDeleteBox == null) return [];
      return pendingDeleteBox.values
          .where((item) => item.status == 'pending')
          .toList();
    } catch (e) {
      print('❌ Error getting pending deletes: $e');
      return [];
    }
  }

  // 🔧 IMPROVED: Get all pending deletes with better error handling
  static Future<List<PendingDelete>> getPendingDeletesAsync() async {
    try {
      if (_pendingDeleteBox == null) {
        await initDeleteBox();
      }

      return pendingDeleteBox.values
          .where((item) => item.status == 'pending')
          .toList();
    } catch (e) {
      print('❌ Error getting pending deletes: $e');
      return [];
    }
  }

  // Update delete status
  static Future<void> updateDeleteStatus(String orderId, String status, {int? retryCount}) async {
    try {
      if (_pendingDeleteBox == null) return;

      final items = pendingDeleteBox.values.where((item) => item.orderId == orderId).toList();

      for (final item in items) {
        item.status = status;
        if (retryCount != null) {
          item.retryCount = retryCount;
        }// Track when last retry happened
        await item.save();
      }

      print('✅ Updated delete status for order $orderId to $status');
    } catch (e) {
      print('❌ Error updating delete status: $e');
    }
  }

  // 🔧 IMPROVED: Remove completed delete with better error handling
  static Future<bool> removePendingDelete(String orderId) async {
    try {
      if (_pendingDeleteBox == null) return false;

      final keys = <dynamic>[];
      bool found = false;

      pendingDeleteBox.toMap().forEach((key, value) {
        if (value.orderId == orderId) {
          keys.add(key);
          found = true;
        }
      });

      if (found) {
        for (final key in keys) {
          await pendingDeleteBox.delete(key);
        }
        print('✅ Removed pending delete for order: $orderId');
      } else {
        print('⚠️ No pending delete found for order: $orderId');
      }

      return found;
    } catch (e) {
      print('❌ Error removing pending delete: $e');
      return false;
    }
  }

  // 🔧 NEW: Get failed deletes that can be retried
  static List<PendingDelete> getFailedDeletes({int maxRetries = 3}) {
    try {
      if (_pendingDeleteBox == null) return [];

      return pendingDeleteBox.values
          .where((item) =>
      item.status == 'failed' &&
          (item.retryCount ?? 0) < maxRetries
      )
          .toList();
    } catch (e) {
      print('❌ Error getting failed deletes: $e');
      return [];
    }
  }

  // 🔧 IMPROVED: Clear old deletes with configurable days
  static Future<void> cleanupOldDeletes({int days = 7}) async {
    try {
      if (_pendingDeleteBox == null) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final keysToDelete = <dynamic>[];

      pendingDeleteBox.toMap().forEach((key, value) {
        if (value.timestamp.isBefore(cutoffDate) &&
            (value.status == 'completed' ||
                value.status == 'failed' && (value.retryCount ?? 0) >= 3)) {
          keysToDelete.add(key);
        }
      });

      if (keysToDelete.isNotEmpty) {
        await pendingDeleteBox.deleteAll(keysToDelete);
        print('✅ Cleaned up ${keysToDelete.length} old delete records');
      }
    } catch (e) {
      print('❌ Error cleaning up old deletes: $e');
    }
  }

  // Get pending delete count
  static int getPendingDeleteCount() {
    try {
      return getPendingDeletes().length;
    } catch (e) {
      print('❌ Error getting pending delete count: $e');
      return 0;
    }
  }

  // 🔧 IMPROVED: Enhanced sync with retry logic
  static Future<void> syncPendingDeletes(dynamic apiProvider) async {
    try {
      final syncService = SyncService();

      // Sync pending deletes
      await syncService.syncPendingDeletes();

      // Also retry failed deletes
      final failedDeletes = getFailedDeletes();
      for (final item in failedDeletes) {
        // Reset status to pending for retry
        await updateDeleteStatus(item.orderId, 'pending');
      }

      // Clean up old records
      await cleanupOldDeletes();

    } catch (e) {
      print('❌ Error in syncPendingDeletes: $e');
    }
  }

  // 🔧 NEW: Get status of a specific order delete
  static String? getDeleteStatus(String orderId) {
    try {
      if (_pendingDeleteBox == null) return null;

      final item = pendingDeleteBox.values
          .where((item) => item.orderId == orderId)
          .firstOrNull;

      return item?.status;
    } catch (e) {
      print('❌ Error getting delete status: $e');
      return null;
    }
  }

  // 🔧 NEW: Clear all pending deletes (for testing/debug)
  static Future<void> clearAllPendingDeletes() async {
    try {
      if (_pendingDeleteBox == null) return;

      await pendingDeleteBox.clear();
      print('✅ Cleared all pending deletes');
    } catch (e) {
      print('❌ Error clearing pending deletes: $e');
    }
  }
}
