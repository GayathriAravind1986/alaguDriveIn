import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';
import 'package:simple/ModelClass/Order/get_order_list_today_model.dart' as order;
import 'package:simple/ModelClass/Order/Get_view_order_model.dart' as view_order;

import '../../../Bloc/Response/errorResponse.dart';
import '../../../Bloc/Response/errorResponse.dart' as view_order;

class HiveOrderTodayService {
  static const String _orderBox = 'orders_today_box';
  static const String _orderDetailsBox = 'order_details_box';
  static const String _orderIdsBox = 'order_ids_box'; // New box to track stored orders

  // ==================== ORDER LIST METHODS ====================

  /// Save API model directly as JSON string AND store all individual orders
  Future<void> saveOrders(order.GetOrderListTodayModel data) async {
    final box = await Hive.openBox(_orderBox);
    final detailsBox = await Hive.openBox(_orderDetailsBox);
    final idsBox = await Hive.openBox(_orderIdsBox);

    // Save the order list
    await box.put('orders_today', jsonEncode(data.toJson()));

    // Save each individual order with its order ID as key
    if (data.data != null) {
      for (var orderItem in data.data!) {
        if (orderItem.id != null) {
          // Convert the order item to a format compatible with GetViewOrderModel
          // This assumes your order item has similar structure to view order details
          final orderDetails = _convertToViewOrderModel(orderItem, data);
          await detailsBox.put(orderItem.id!, jsonEncode(orderDetails.toJson()));
          await idsBox.put(orderItem.id!, true); // Mark as stored
        }
      }
    }

    debugPrint("✅ Orders saved offline as JSON string with ${data.data?.length ?? 0} individual orders");
  }

  /// Helper method to convert order list item to view order model
  view_order.GetViewOrderModel _convertToViewOrderModel(
      order.Data orderItem,
      order.GetOrderListTodayModel orderList
      ) {
    // You'll need to adapt this based on your actual model structures
    return view_order.GetViewOrderModel(
      success: orderList.success,
      data: view_order.Data(
        id: orderItem.id,
        orderNumber: orderItem.orderNumber,
        orderType: orderItem.orderType,
        orderStatus: orderItem.orderStatus,
        // Add other fields as needed from orderItem
        invoice: view_order.Invoice(
          // Map invoice fields if available in orderItem
          businessName: 'Alagu DriveIn', // Example
          // Add other invoice fields
        ),
      ),
      errorResponse: orderList.errorResponse != null
          ? view_order.ErrorResponse(
        message: orderList.errorResponse!.message,
        statusCode: orderList.errorResponse!.statusCode,
      )
          : null,
    );
  }

  /// Read API model back from JSON string
  Future<order.GetOrderListTodayModel?> getOrders() async {
    final box = await Hive.openBox(_orderBox);
    final data = box.get('orders_today');
    if (data != null) {
      final decoded = jsonDecode(data);
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

  /// Save individual order details with order ID as key
  Future<void> saveOrderDetails(String orderId, view_order.GetViewOrderModel orderData) async {
    final box = await Hive.openBox(_orderDetailsBox);
    final idsBox = await Hive.openBox(_orderIdsBox);
    await box.put(orderId, jsonEncode(orderData.toJson()));
    await idsBox.put(orderId, true); // Mark as stored
    debugPrint("✅ Order details for $orderId saved offline");
  }

  /// Get individual order details by order ID
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
      debugPrint("Error reading order details from Hive: $e");
      return null;
    }
  }

  /// Check if we have detailed data for a specific order
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

  /// Clear all individual orders from cache
  Future<void> clearAllOrderDetails() async {
    final box = await Hive.openBox(_orderDetailsBox);
    final idsBox = await Hive.openBox(_orderIdsBox);
    await box.clear();
    await idsBox.clear();
    debugPrint("✅ All order details cleared");
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all cached data (both order list and individual orders)
  Future<void> clearAllCache() async {
    await clearOrders();
    await clearAllOrderDetails();
    debugPrint("✅ All order cache cleared");
  }

  /// Get all cached order IDs (for debugging or management)
  Future<List<String>> getAllCachedOrderIds() async {
    final idsBox = await Hive.openBox(_orderIdsBox);
    return idsBox.keys.whereType<String>().toList();
  }

  /// Check if a specific order is cached
  Future<bool> isOrderCached(String orderId) async {
    final idsBox = await Hive.openBox(_orderIdsBox);
    return idsBox.containsKey(orderId);
  }

  /// Get count of cached orders
  Future<int> getCachedOrdersCount() async {
    final idsBox = await Hive.openBox(_orderIdsBox);
    return idsBox.length;
  }
}