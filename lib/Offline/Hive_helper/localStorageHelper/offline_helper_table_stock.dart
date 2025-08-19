import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service_table_stock.dart';

class OfflineStatusHelper {
  static Future<bool> hasOfflineData() async {
    final stock = await HiveStockTableService.getStockMaintenance();
    final tables = await HiveStockTableService.getTables();
    return stock != null || tables.isNotEmpty;
  }

  static Future<String> getOfflineStatus() async {
    final stockTime = await HiveStockTableService.getLastStockUpdateTime();
    final tablesTime = await HiveStockTableService.getLastTablesUpdateTime();

    if (stockTime == null && tablesTime == null) {
      return 'No offline data';
    }

    final latestTime = [stockTime, tablesTime]
        .where((time) => time != null)
        .map((time) => time!)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final now = DateTime.now();
    final difference = now.difference(latestTime);

    if (difference.inDays > 0) {
      return 'Last updated ${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return 'Last updated ${difference.inHours} hours ago';
    } else {
      return 'Recently updated';
    }
  }
}
