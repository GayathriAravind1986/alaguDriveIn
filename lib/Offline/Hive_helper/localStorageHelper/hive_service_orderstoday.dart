import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart' as order;

class HiveOrderTodayService {
  static const String _orderBox = 'orders_today_box';

  /// Save API model directly as JSON string
  Future<void> saveOrders(order.GetOrderListTodayModel data) async {
    final box = await Hive.openBox(_orderBox);
    await box.put('orders_today', jsonEncode(data.toJson())); // ✅ encode to string
    debugPrint("✅ Orders saved offline as JSON string");
  }

  /// Read API model back from JSON string
  Future<order.GetOrderListTodayModel?> getOrders() async {
    final box = await Hive.openBox(_orderBox);
    final data = box.get('orders_today');
    if (data != null) {
      final decoded = jsonDecode(data); // ✅ decode string
      return order.GetOrderListTodayModel.fromJson(decoded);
    }
    return null;
  }

  /// Clear offline cache
  Future<void> clearOrders() async {
    final box = await Hive.openBox(_orderBox);
    await box.delete('orders_today');
  }
}
