// lib/Offline/Hive_helper/hive_order_today_service.dart
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart'
    as order;
import 'package:simple/ModelClass/Order/Get_view_order_model.dart'
    as view_order;
import 'package:simple/Offline/Hive_helper/localStorageHelper/hive_service.dart'; // << new import

/// Service for saving & retrieving orders in Hive (with full API format)
class HiveOrderTodayService {
  static const String _orderBox = 'orders_today_box';
  static const String _orderDetailsBox = 'order_details_box';
  static const String _orderIdsBox = 'order_ids_box'; // Track stored order IDs

  // ==================== ORDER LIST METHODS ====================

  /// Save full API order list and each order’s details
  Future<void> saveOrders(order.GetOrderListTodayModel data) async {
    final box = await Hive.openBox(_orderBox);
    final detailsBox = await Hive.openBox(_orderDetailsBox);
    final idsBox = await Hive.openBox(_orderIdsBox);

    await box.put('orders_today', jsonEncode(data.toJson()));

    // Save each order detail in full API format
    if (data.data != null) {
      for (var orderItem in data.data!) {
        if (orderItem.id != null) {
          // Convert list item to full view order JSON
          final fullOrder = view_order.GetViewOrderModel(
            success: true,
            data: view_order.Data.fromJson(orderItem.toJson()),
          );
          await detailsBox.put(orderItem.id!, jsonEncode(fullOrder.toJson()));
          await idsBox.put(orderItem.id!, true);
        }
      }

      // After saving all, determine "latest" order id to persist as last-online id.
      // Strategy: try to parse trailing digits and pick maximum numeric; fallback to last element raw id.
      String? bestRaw;
      int bestNum = -1;
      int bestNumLen = 0;
      final regex = RegExp(r'(\d+)$');

      for (var orderItem in data.data!) {
        if (orderItem.id == null) continue;
        final raw = orderItem.id!;
        final match = regex.firstMatch(raw);
        if (match != null) {
          final digits = match.group(1)!;
          final num = int.tryParse(digits) ?? -1;
          if (num > bestNum) {
            bestNum = num;
            bestRaw = raw;
            bestNumLen = digits.length;
          }
        } else {
          // if none have digits, just pick the last available as fallback
          if (bestRaw == null) bestRaw = raw;
        }
      }

      if (bestRaw != null) {
        try {
          // Save the raw id, HiveService will extract prefix + numeric details
          await HiveService.saveLastOnlineOrderIdRaw(bestRaw);
          debugPrint(
              "💾 Saved last online order id (from list): $bestRaw (num: $bestNum)");
        } catch (e) {
          debugPrint("❌ Failed saving last online order id: $e");
        }
      }
    }

    debugPrint("✅ Orders saved offline with ${data.data?.length ?? 0} entries");
  }

  /// Read back the full order list
  Future<order.GetOrderListTodayModel?> getOrders() async {
    final box = await Hive.openBox(_orderBox);
    final data = box.get('orders_today');
    if (data != null) {
      final decoded = jsonDecode(data);
      debugPrint(
          "📥 Retrieved orders_today with ${(decoded['data'] as List).length} orders");
      return order.GetOrderListTodayModel.fromJson(decoded);
    }
    return null;
  }

  /// Clear orders list cache
  Future<void> clearOrders() async {
    final box = await Hive.openBox(_orderBox);
    final idsBox = await Hive.openBox(_orderIdsBox);
    await box.delete('orders_today');
    await idsBox.clear();
    debugPrint("✅ Orders list and tracking cleared");
  }

  // ==================== INDIVIDUAL ORDER METHODS ====================

  /// Save full order details with order ID as key
  Future<void> saveOrderDetails(
      String orderId, view_order.GetViewOrderModel orderData) async {
    final box = await Hive.openBox(_orderDetailsBox);
    final idsBox = await Hive.openBox(_orderIdsBox);

    await box.put(orderId, jsonEncode(orderData.toJson()));
    await idsBox.put(orderId, true);

    debugPrint("✅ Order details for $orderId saved offline");
  }

  /// Get order details by order ID
  Future<view_order.GetViewOrderModel?> getOrderDetails(String orderId) async {
    try {
      final box = await Hive.openBox(_orderDetailsBox);
      final data = box.get(orderId);
      if (data != null) {
        final decoded = jsonDecode(data);
        return view_order.GetViewOrderModel.fromJson(decoded);
      }
      return null;
    } catch (e) {
      debugPrint("❌ Error reading order details from Hive: $e");
      return null;
    }
  }

  /// Check if order details exist for specific order
  Future<bool> hasOrderDetails(String orderId) async {
    final idsBox = await Hive.openBox(_orderIdsBox);
    return idsBox.containsKey(orderId);
  }

  /// Clear specific order from cache
  Future<void> clearOrder(String orderId) async {
    final box = await Hive.openBox(_orderDetailsBox);
    final idsBox = await Hive.openBox(_orderIdsBox);
    await box.delete(orderId);
    await idsBox.delete(orderId);
    debugPrint("✅ Order $orderId cleared from cache");
  }

  /// Clear all individual orders
  Future<void> clearAllOrderDetails() async {
    final box = await Hive.openBox(_orderDetailsBox);
    final idsBox = await Hive.openBox(_orderIdsBox);
    await box.clear();
    await idsBox.clear();
    debugPrint("✅ All order details cleared");
  }

  // ==================== UTILITY METHODS ====================

  /// Clear everything
  Future<void> clearAllCache() async {
    await clearOrders();
    await clearAllOrderDetails();
    debugPrint("✅ All order cache cleared");
  }

  /// Get all cached order IDs
  Future<List<String>> getAllCachedOrderIds() async {
    final idsBox = await Hive.openBox(_orderIdsBox);
    return idsBox.keys.whereType<String>().toList();
  }

  /// Check if specific order is cached
  Future<bool> isOrderCached(String orderId) async {
    final idsBox = await Hive.openBox(_orderIdsBox);
    return idsBox.containsKey(orderId);
  }

  /// Get number of cached orders
  Future<int> getCachedOrdersCount() async {
    final idsBox = await Hive.openBox(_orderIdsBox);
    return idsBox.length;
  }

  Future<order.GetOrderListTodayModel?> getFilteredOrders({
    String? tableId,
    String? waiterId,
    String? userId,
    String? fromDate,
    String? toDate,
  }) async {
    final orders = await getOrders();
    if (orders == null || orders.data == null || orders.data!.isEmpty) {
      return orders;
    }

    // Check if any filters are applied
    final hasTableFilter = tableId != null &&
        tableId.isNotEmpty &&
        tableId != "0" &&
        tableId.toLowerCase() != "all";
    final hasWaiterFilter = waiterId != null &&
        waiterId.isNotEmpty &&
        waiterId != "0" &&
        waiterId.toLowerCase() != "all";
    final hasUserFilter = userId != null &&
        userId.isNotEmpty &&
        userId != "0" &&
        userId.toLowerCase() != "all";
    final hasDateFilter = (fromDate != null && fromDate.isNotEmpty) ||
        (toDate != null && toDate.isNotEmpty);

    // If no filters, return all
    if (!hasTableFilter &&
        !hasWaiterFilter &&
        !hasUserFilter &&
        !hasDateFilter) {
      return orders;
    }

    // Apply filters
    final filteredData = orders.data!.where((orderItem) {
      // Table filter
      if (hasTableFilter) {
        final orderTableId = orderItem.tableNo?.toString() ?? '';
        if (orderTableId != tableId) return false;
      }

      // Waiter filter
      if (hasWaiterFilter) {
        final orderWaiterId = orderItem.waiter?.toString() ?? '';
        if (orderWaiterId != waiterId) return false;
      }

      // User filter
      if (hasUserFilter) {
        final orderUserId = orderItem.operator?.id.toString() ?? '';
        if (orderUserId != userId) return false;
      }

      return true;
    }).toList();

    debugPrint(
        '🔍 Filtered: ${orders.data!.length} → ${filteredData.length} orders');

    return order.GetOrderListTodayModel(
      success: orders.success,
      data: filteredData,
      errorResponse: orders.errorResponse,
    );
  }

  /// Get statistics for cached orders (useful for debugging)
  Future<Map<String, dynamic>> getCacheStatistics() async {
    final orders = await getOrders();
    if (orders?.data == null) {
      return {'total': 0, 'tables': [], 'waiters': [], 'users': []};
    }

    final tables = <String>{};
    final waiters = <String>{};
    final users = <String>{};

    for (var order in orders!.data!) {
      if (order.tableNo != null) tables.add(order.tableNo.toString());
      if (order.waiter != null) waiters.add(order.waiter.toString());
      if (order.operator?.id != null) users.add(order.operator!.id.toString());
    }

    return {
      'total': orders.data!.length,
      'tables': tables.toList()..sort(),
      'waiters': waiters.toList()..sort(),
      'users': users.toList()..sort(),
    };
  }
}
