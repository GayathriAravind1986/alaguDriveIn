import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/Order/Delete_order_model.dart';
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive-pending_delete_service.dart';
import 'package:simple/Reusable/constant.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  SyncService._internal();
  factory SyncService() => _instance;

  bool _isSyncing = false;

  Future<void> syncPendingDeletes() async {
    if (_isSyncing) {
      print("⏳ Sync already in progress, skipping...");
      return;
    }

    _isSyncing = true;
    print("🔄 Starting sync of pending deletes...");

    try {
      final pending = HiveServicedelete.getPendingDeletes();
      print("📋 Found ${pending.length} pending deletes to sync");

      for (final item in pending) {
        try {
          print("🔄 Syncing delete for order: ${item.orderId}");

          // 🔧 FIXED: Use direct API call to avoid recursion
          final response = await _performActualDelete(item.orderId);

          if (response.errorResponse == null) {
            // Success - remove from pending
            await HiveServicedelete.removePendingDelete(item.orderId);
            print("✅ Successfully synced delete for order: ${item.orderId}");
          } else {
            // Failed - update retry count
            await HiveServicedelete.updateDeleteStatus(
              item.orderId,
              'failed',
              retryCount: (item.retryCount ?? 0) + 1,
            );
            print("❌ Failed to sync delete for order: ${item.orderId}");
          }
        } catch (e) {
          print("❌ Error syncing order ${item.orderId}: $e");
          await HiveServicedelete.updateDeleteStatus(
            item.orderId,
            'failed',
            retryCount: (item.retryCount ?? 0) + 1,
          );
        }
      }

      // Clean up old failed records
      await HiveServicedelete.cleanupOldDeletes();

      print("✅ Sync completed");
    } catch (e) {
      print("❌ Sync process error: $e");
    } finally {
      _isSyncing = false;
    }
  }

  // 🔧 FIXED: Direct API call method that doesn't trigger offline save
  Future<DeleteOrderModel> _performActualDelete(String orderId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString("token");

    if (token == null || token.isEmpty) {
      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(
          message: "Authorization token missing",
          statusCode: 401,
        );
    }

    try {
      final dio = Dio();
      final response = await dio.request(
        '${Constants.baseUrl}api/generate-order/order/$orderId',
        options: Options(
          method: 'DELETE',
          headers: {'Authorization': 'Bearer $token'},
          // connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['success'] == true) {
          return DeleteOrderModel.fromJson(response.data);
        }
      }

      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(
          message: response.data?['message'] ?? 'Unknown error',
          statusCode: response.statusCode ?? 500,
        );

    } on DioException catch (dioError) {
      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(
          message: "Network error: ${dioError.message}",
          statusCode: dioError.response?.statusCode ?? 500,
        );
    } catch (error) {
      return DeleteOrderModel()
        ..errorResponse = ErrorResponse(
          message: "Unexpected error: $error",
          statusCode: 500,
        );
    }
  }

  bool get isSyncing => _isSyncing;
}
