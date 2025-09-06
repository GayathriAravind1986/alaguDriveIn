// hive_waiter_service.dart
import 'package:hive/hive.dart';
import 'package:simple/ModelClass/Waiter/getWaiterModel.dart' as waiter;
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_waiter_model.dart';

class HiveWaiterService {
  static const String _waiterBox = 'waiters_box'; // Changed to match table pattern
  static const String _appStateBox = 'app_state';

  static Future<void> saveWaiters(List<waiter.Data> waitersData) async {
    final box = Hive.box<HiveWaiter>('waiters_box');
    await box.clear();

    for (int i = 0; i < waitersData.length; i++) {
      final hiveWaiter = HiveWaiter.fromApiModel(waitersData[i]);
      await box.put('waiter_$i', hiveWaiter);
    }

    // Save metadata
    final appStateBox = Hive.box(_appStateBox);
    await appStateBox.put('waiters_last_updated', DateTime.now().toIso8601String());
  }

  static Future<List<HiveWaiter>> getWaiters() async {
    final box = Hive.box<HiveWaiter>(_waiterBox);
    return box.values.toList();
  }

  static Future<List<waiter.Data>> getWaitersAsApiFormat() async {
    final hiveWaiters = await getWaiters();
    return hiveWaiters.map((hiveWaiter) => hiveWaiter.toApiModel()).toList();
  }

  static Future<DateTime?> getLastUpdated() async {
    final appStateBox = Hive.box(_appStateBox);
    final dateString = appStateBox.get('waiters_last_updated');
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  static Future<void> clearWaiters() async {
    final box = Hive.box<HiveWaiter>(_waiterBox);
    await box.clear();
  }
}
