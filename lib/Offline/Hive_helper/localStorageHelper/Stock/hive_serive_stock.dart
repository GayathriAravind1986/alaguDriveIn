import 'package:hive/hive.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Stock/hive_pending_stock_model.dart';

class HiveStockService {
  static const String _boxName = 'pending_stock';

  /// Ensure box is opened before use
  static Future<Box<HivePendingStock>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<HivePendingStock>(_boxName);
    }
    return Hive.box<HivePendingStock>(_boxName);
  }

  static Future<void> savePendingStock(String payload) async {
    final box = await _openBox();
    final pending = HivePendingStock()
      ..id = DateTime.now().millisecondsSinceEpoch.toString()
      ..payload = payload
      ..createdAt = DateTime.now();

    await box.add(pending);

    print("✅ Saved pending stock offline: ${pending.id}");
    await debugPrintPendingStocks();
  }

  static Future<void> syncPendingStock(ApiProvider apiProvider) async {
    final box = await _openBox();

    if (box.isEmpty) {
      print("📦 No pending stocks to sync");
      return;
    }

    final items = box.values.toList();
    print("🔄 Syncing ${items.length} pending stock(s)...");

    for (var item in items) {
      try {
        final response = await apiProvider.postSaveStockInAPI(item.payload!);

        if (response.success == true && response.errorResponse == null) {
          await item.delete();
          print("✅ Synced and removed pending stock ${item.id}");
        } else {
          print("⚠️ Sync failed, keeping item ${item.id}: ${response.errorResponse?.message}");
        }
      } catch (e) {
        print("❌ Sync failed for ${item.id}: $e");
      }
    }

    await debugPrintPendingStocks();
  }

  static Future<void> debugPrintPendingStocks() async {
    final box = await _openBox();
    print("📦 Pending stock count: ${box.length}");
    for (var item in box.values) {
      print("📝 Pending stock: ${item.payload}");
    }
  }
}
