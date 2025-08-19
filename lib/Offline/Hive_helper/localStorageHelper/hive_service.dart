// hive_service.dart
import 'package:hive/hive.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_billing_session_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_cart_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_order_model.dart';
import 'package:uuid/uuid.dart';

class HiveService {
  static const String CART_BOX = 'cart_items';
  static const String ORDERS_BOX = 'orders';
  static const String BILLING_SESSION_BOX = 'billing_session';
  static const String SYNC_QUEUE_BOX = 'sync_queue';

  // Cart Management
  static Future<void> saveCartItems(
      List<Map<String, dynamic>> billingItems) async {
    final cartBox = await Hive.openBox<HiveCartItem>(CART_BOX);
    await cartBox.clear(); // Clear existing cart

    for (var item in billingItems) {
      final hiveItem = HiveCartItem.fromMap(item);
      await cartBox.add(hiveItem);
    }
  }

  static Future<List<HiveCartItem>> getCartItems() async {
    final cartBox = await Hive.openBox<HiveCartItem>(CART_BOX);
    return cartBox.values.toList();
  }

  static Future<void> clearCart() async {
    final cartBox = await Hive.openBox<HiveCartItem>(CART_BOX);
    await cartBox.clear();
  }

  // Billing Session Management
  static Future<void> saveBillingSession(HiveBillingSession session) async {
    final billingBox =
        await Hive.openBox<HiveBillingSession>(BILLING_SESSION_BOX);
    await billingBox.clear();
    await billingBox.add(session);
  }

  static Future<HiveBillingSession?> getBillingSession() async {
    final billingBox =
        await Hive.openBox<HiveBillingSession>(BILLING_SESSION_BOX);
    return billingBox.values.isNotEmpty ? billingBox.values.first : null;
  }

  static Future<void> clearBillingSession() async {
    final billingBox =
        await Hive.openBox<HiveBillingSession>(BILLING_SESSION_BOX);
    await billingBox.clear();
  }

  // Calculate billing totals offline
  static HiveBillingSession calculateBillingTotals(
      List<Map<String, dynamic>> billingItems, bool isDiscountApplied) {
    double subtotal = 0.0;
    double totalTax = 0.0;
    double totalDiscount = 0.0;

    for (var item in billingItems) {
      double basePrice = (item['basePrice'] ?? 0.0).toDouble();
      int qty = item['qty'] ?? 1;
      double itemTotal = basePrice * qty;

      // Calculate addon costs
      List<dynamic> selectedAddons = item['selectedAddons'] ?? [];
      for (var addon in selectedAddons) {
        if (!(addon['isFree'] ?? false)) {
          double addonPrice = (addon['price'] ?? 0.0).toDouble();
          int addonQty = addon['quantity'] ?? 0;
          itemTotal += (addonPrice * addonQty);
        }
      }

      subtotal += itemTotal;
    }

    // Simplified tax calculation (you can adjust based on your business logic)
    // totalTax = subtotal * 0.18; // 18% tax

    if (isDiscountApplied) {
      totalDiscount = subtotal * 0.1; // 10% discount
    }

    double total = subtotal + totalTax - totalDiscount;

    return HiveBillingSession(
      items: billingItems.map((item) => HiveCartItem.fromMap(item)).toList(),
      isDiscountApplied: isDiscountApplied,
      subtotal: subtotal,
      totalTax: totalTax,
      total: total,
      totalDiscount: totalDiscount,
      lastUpdated: DateTime.now(),
    );
  }

  // Order Management
  static Future<String> saveOfflineOrder({
    required String orderPayloadJson,
    required String orderStatus,
    required String orderType,
    String? tableId,
    required double total,
    required List<Map<String, dynamic>> items,
    String syncAction = 'CREATE',
    String? existingOrderId,
  }) async {
    final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
    final orderId = const Uuid().v4();

    final order = HiveOrder(
      id: orderId,
      orderPayloadJson: orderPayloadJson,
      orderStatus: orderStatus,
      orderType: orderType,
      tableId: tableId,
      total: total,
      createdAt: DateTime.now(),
      isSynced: false,
      items: items.map((item) => HiveCartItem.fromMap(item)).toList(),
      syncAction: syncAction,
      existingOrderId: existingOrderId,
    );

    await ordersBox.put(orderId, order);
    return orderId;
  }

  static Future<List<HiveOrder>> getPendingSyncOrders() async {
    final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
    return ordersBox.values.where((order) => !order.isSynced!).toList();
  }

  static Future<void> markOrderAsSynced(String orderId) async {
    final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
    final order = ordersBox.get(orderId);
    if (order != null) {
      order.isSynced = true;
      await order.save();
    }
  }

  static Future<void> deleteOrder(String orderId) async {
    final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
    await ordersBox.delete(orderId);
  }

  static Future<List<HiveOrder>> getAllOrders() async {
    final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
    return ordersBox.values.toList();
  }

  // Sync Management
  static Future<void> syncPendingOrders(ApiProvider apiProvider) async {
    final pendingOrders = await getPendingSyncOrders();

    for (var order in pendingOrders) {
      try {
        if (order.syncAction == 'CREATE') {
          await apiProvider.postGenerateOrderAPI(order.orderPayloadJson!);
        } else if (order.syncAction == 'UPDATE') {
          await apiProvider.updateGenerateOrderAPI(
              order.orderPayloadJson!, order.existingOrderId);
        }

        // Mark as synced if successful
        await markOrderAsSynced(order.id!);
      } catch (e) {
        print('Failed to sync order ${order.id}: $e');
        // Keep order in pending state for retry
      }
    }
  }

  // Check if device is offline based on last successful API call
  static Future<void> saveLastOnlineTimestamp() async {
    final box = await Hive.openBox('app_state');
    await box.put('last_online', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> isLikelyOffline() async {
    try {
      final box = await Hive.openBox('app_state');
      final lastOnline = box.get('last_online');
      if (lastOnline == null) return false;

      final lastOnlineTime = DateTime.fromMillisecondsSinceEpoch(lastOnline);
      final difference = DateTime.now().difference(lastOnlineTime);

      // Consider offline if no successful API call in last 5 minutes
      return difference.inMinutes > 5;
    } catch (e) {
      return false;
    }
  }
}
