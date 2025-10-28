import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_billing_session_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_cart_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_order_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/product_model.dart';
import 'package:uuid/uuid.dart';

import '../LocalClass/Home/category_model.dart';

class HiveService {
  static const String CART_BOX = 'cart_items';
  static const String ORDERS_BOX = 'orders';
  static const String BILLING_SESSION_BOX = 'billing_session';
  static const String SYNC_QUEUE_BOX = 'sync_queue';
  static const String orderTypeBoxName = 'order_type';
  static const String MASTER_PRODUCTS_BOX = 'master_products';
  static Box? _pendingActionsBox;

  static Future<Box> getPendingActionsBox() async {
    if (_pendingActionsBox == null || !_pendingActionsBox!.isOpen) {
      _pendingActionsBox = await Hive.openBox('pendingActions');
    }
    return _pendingActionsBox!;
  }

  static Future<void> closeBox() async {
    if (_pendingActionsBox != null && _pendingActionsBox!.isOpen) {
      await _pendingActionsBox!.close();
    }
  }

  // Cart Management
  static Future<void> saveCartItems(
      List<Map<String, dynamic>> billingItems, [
        String? categoryId,
      ]) async {
    final cartBox = await Hive.openBox<HiveCartItem>(CART_BOX);
    await cartBox.clear();

    if (categoryId != null) {
      debugPrint("🟢 Offline SaveCartItems for category: $categoryId");

      final productBox =
      await Hive.openBox<HiveProduct>('products_$categoryId');

      for (var item in billingItems) {
        final productId = item['_id'] ?? item['id'] ?? item['product'];

        // Find product in Hive
        HiveProduct? product;
        try {
          product = productBox.values.firstWhere(
                (p) => p.id == productId,
          );
        } catch (e) {
          product = HiveProduct(
            id: productId,
            name: item['name'] ?? 'Unknown Product',
            basePrice: (item['basePrice'] ?? 0.0).toDouble(),
            parcelPrice: (item['parcelPrice'] ?? 0.0).toDouble(),
            acPrice: (item['acPrice'] ?? 0.0).toDouble(),
            swiggyPrice: (item['swiggyPrice'] ?? 0.0).toDouble(),
            hdPrice: (item['hdPrice'] ?? 0.0).toDouble(),
          );
        }

        // Create HiveCartItem with ALL price fields properly set
        final hiveItem = HiveCartItem(
          id: product.id,
          product: product.id,
          name: product.name,
          image: product.image,
          quantity: item['quantity'] ?? 1,
          qty: item['quantity'] ?? 1,
          availableQuantity:
          item['availableQuantity'] ?? (item['quantity'] ?? 1),

          // ✅ CRITICAL: Set ALL price fields from product
          basePrice: product.basePrice ?? 0.0,
          unitPrice: product.basePrice ?? 0.0, // Initialize with basePrice
          acPrice: product.acPrice ?? 0.0,
          parcelPrice: product.parcelPrice ?? 0.0,
          swiggyPrice: product.swiggyPrice ?? 0.0,
          hdPrice: product.hdPrice ?? 0.0,

          // Addons and other fields
          selectedAddons: (item['selectedAddons'] as List?)
              ?.map((addon) => Map<String, dynamic>.from(addon as Map))
              .toList(),
          isFree: item['isFree'] ?? false,
        );

        await cartBox.add(hiveItem);
      }
    } else {
      // ONLINE MODE - Prices should already be in the map
      for (var item in billingItems) {
        try {
          final hiveItem = HiveCartItem.fromMap(item);

          debugPrint("   ✅ Converted to HiveCartItem:");
          debugPrint("      Base: ${hiveItem.basePrice}");
          debugPrint("      AC: ${hiveItem.acPrice}");
          debugPrint("      Parcel: ${hiveItem.parcelPrice}");
          debugPrint("      Swiggy: ${hiveItem.swiggyPrice}");
          debugPrint("      HD: ${hiveItem.hdPrice}");

          await cartBox.add(hiveItem);
        } catch (e, st) {
          debugPrint("❌ Error converting item ${item['name']}: $e");
          debugPrint("Stack trace: $st");
        }
      }
    }

    final savedCount = cartBox.length;
    debugPrint("✅ Total items saved to cart: $savedCount");
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

  /// Save current order type
  static Future<void> saveOrderType(String orderType) async {
    final box = await Hive.openBox<String>(orderTypeBoxName);
    await box.put('current_order_type', orderType);
  }

  /// Get current order type
  static Future<String?> getCurrentOrderType() async {
    final box = await Hive.openBox<String>(orderTypeBoxName);
    return box.get('current_order_type');
  }

  // Calculate billing totals offline
  static Future<HiveBillingSession> calculateBillingTotals(
      List<Map<String, dynamic>> billingItems,
      bool isDiscount, {
        String? orderType,
        String? categoryId, // Add categoryId parameter
      }) async {
    double subtotal = 0.0;
    double totalTax = 0.0;
    double totalDiscount = 0.0;

    List<HiveCartItem> hiveItems = [];

    // Open the correct product box based on categoryId
    Box<HiveProduct> productBox;
    if (categoryId != null) {
      productBox = await Hive.openBox<HiveProduct>('products_$categoryId');
    } else {
      productBox = await Hive.openBox<HiveProduct>('products');
    }

    for (int i = 0; i < billingItems.length; i++) {
      var item = billingItems[i];

      final productId = item['id']?.toString() ??
          item['product']?.toString() ??
          item['productId']?.toString() ??
          item['_id']?.toString();

      // Fetch product from Hive to get all prices
      HiveProduct? hiveProduct;
      try {
        hiveProduct = productBox.values.firstWhere(
              (p) => p.id == productId,
        );
      } catch (e) {
        hiveProduct = HiveProduct(
          id: productId,
          name: item['name'] ?? 'Unknown Product',
          basePrice: (item['basePrice'] ?? 0.0).toDouble(),
          parcelPrice: (item['parcelPrice'] ?? 0.0).toDouble(),
          acPrice: (item['acPrice'] ?? 0.0).toDouble(),
          swiggyPrice: (item['swiggyPrice'] ?? 0.0).toDouble(),
          hdPrice: (item['hdPrice'] ?? 0.0).toDouble(),
        );
      }

      // Merge item data with product prices from Hive
      final mergedItem = {
        ...item,
        'basePrice': hiveProduct.basePrice,
        'acPrice': hiveProduct.acPrice,
        'parcelPrice': hiveProduct.parcelPrice,
        'swiggyPrice': hiveProduct.swiggyPrice,
        'hdPrice': hiveProduct.hdPrice,
      };

      final hiveItem = HiveCartItem.fromMap(mergedItem);

      // ✅ Get correct price based on order type
      double itemPrice = hiveItem.getPriceByOrderType(orderType);
      int itemQty = hiveItem.quantity ?? 1;

      // 🧩 Calculate addon total
      double addonTotal = 0.0;
      if (hiveItem.selectedAddons != null) {
        for (var addon in hiveItem.selectedAddons!) {
          if (!(addon['isFree'] ?? false)) {
            double addonPrice = (addon['price'] ?? 0.0).toDouble();
            int addonQty = addon['quantity'] ?? 0;
            double addonSubtotal = addonPrice * addonQty;
            addonTotal += addonSubtotal;
          }
        }
      }

      // 🧾 Calculate item subtotal (base price + addons) * quantity
      double itemSubtotal = (itemPrice + addonTotal) * itemQty;

      // Update hiveItem with calculated values
      hiveItem.unitPrice = itemPrice;
      hiveItem.basePrice = itemPrice;
      hiveItem.subtotal = itemSubtotal;

      // 💰 Calculate tax (18%)
      double itemTax = itemSubtotal * 0.0;
      hiveItem.taxPrice = itemTax;

      // 💵 Total per item
      hiveItem.totalPrice = itemSubtotal + itemTax;

      subtotal += itemSubtotal;
      totalTax += itemTax;

      hiveItems.add(hiveItem);
    }

    // 🎁 Apply discount if needed
    if (isDiscount) {
      totalDiscount = subtotal * 0.1; // 10%
      subtotal -= totalDiscount;
    }

    double total = subtotal + totalTax;

    return HiveBillingSession(
      isDiscountApplied: isDiscount,
      subtotal: subtotal,
      totalTax: totalTax,
      total: total,
      totalDiscount: totalDiscount,
      items: hiveItems,
      orderType: orderType,
      lastUpdated: DateTime.now(),
    );
  }

  // UPDATED METHOD: Update product quantities in ALL storage locations
  static Future<void> updateProductQuantities(List<Map<String, dynamic>> items) async {
    try {
      debugPrint("🔄 Updating product quantities for ${items.length} items...");

      for (var item in items) {
        final productId = item['product']?.toString();
        final quantity = item['quantity'] ?? 1;

        if (productId == null) {
          debugPrint("⚠️ Skipping item with null product ID: $item");
          continue;
        }

        debugPrint("🔍 Looking for product: $productId, quantity to deduct: $quantity");

        // Update quantity in ALL storage locations
        await _updateProductQuantityEverywhere(productId, quantity);
      }

      debugPrint("✅ Product quantity update completed");
    } catch (e, stackTrace) {
      debugPrint("❌ Error updating product quantities: $e");
      debugPrint("❌ Stack trace: $stackTrace");
    }
  }

  // UPDATED HELPER: Update quantity in ALL boxes including ALL category boxes
  static Future<void> _updateProductQuantityEverywhere(String productId, int quantity) async {
    try {
      int updateCount = 0;

      // 1. Try master products box
      if (await _updateQuantityInBox('master_products', productId, quantity)) {
        updateCount++;
        debugPrint("   ✅ Updated in master box");
      }

      // 2. UPDATED: Use actual category IDs from categories box
      // Import the method from local_storage_product.dart or duplicate the logic
      final categoryIds = await _getAllCategoryIds(); // You'll need to add this method to hive_service.dart too
      debugPrint("   🔍 Searching in ${categoryIds.length} actual categories...");

      for (var categoryId in categoryIds) {
        final boxName = 'products_$categoryId';
        if (await _updateQuantityInBox(boxName, productId, quantity)) {
          updateCount++;
          debugPrint("   ✅ Updated in category box: $boxName");
        }
      }

      if (updateCount == 0) {
        debugPrint("❌ Product $productId not found in any storage location");
      } else {
        debugPrint("✅ Successfully updated quantity for product: $productId in $updateCount locations");
      }
    } catch (e) {
      debugPrint("❌ Error in _updateProductQuantityEverywhere: $e");
    }
  }

  // Add this method to hive_service.dart as well:
  static Future<List<String>> _getAllCategoryIds() async {
    try {
      final categoriesBox = await Hive.openBox<HiveCategory>('categories');
      final allCategories = categoriesBox.values.toList();

      final categoryIds = allCategories
          .map((category) => category.id)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toList();

      categoryIds.add("");

      debugPrint("📂 Found ${categoryIds.length} categories in categories box");
      return categoryIds;
    } catch (e) {
      debugPrint('❌ Error getting category IDs: $e');
      return ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']; // Fallback
    }
  }

  // Generic method to update quantity in a specific box
  static Future<bool> _updateQuantityInBox(String boxName, String productId, int quantity) async {
    try {
      debugPrint("   🔎 Searching in box: $boxName");
      final box = await Hive.openBox<HiveProduct>(boxName);

      // Get all products and search manually
      final allProducts = box.values.toList();
      for (var product in allProducts) {
        if (product.id == productId) {
          final currentQuantity = product.availableQuantity ?? 0;
          final newQuantity = currentQuantity - quantity;

          debugPrint("   📦 FOUND: ${product.name} in $boxName");
          debugPrint("      Current quantity: $currentQuantity");
          debugPrint("      Quantity to deduct: $quantity");
          debugPrint("      New quantity: ${newQuantity > 0 ? newQuantity : 0}");

          product.availableQuantity = newQuantity > 0 ? newQuantity : 0;
          await box.put(productId, product);
          debugPrint("   ✅ UPDATED: ${product.name} to ${product.availableQuantity} in $boxName");
          return true;
        }
      }
      debugPrint("   ❌ Product $productId not found in $boxName");
      return false;
    } catch (e) {
      // Box might not exist or other error - just continue
      debugPrint("   ⚠️ Could not access box $boxName: $e");
      return false;
    }
  }

  // Order Management - MODIFIED to ensure quantity update
  static Future<String> saveOfflineOrder({
    required String orderPayloadJson,
    required String orderStatus,
    required String orderType,
    String? tableId,
    required double total,
    required List<Map<String, dynamic>> items,
    String syncAction = 'CREATE',
    String? existingOrderId,
    String? businessName,
    String? address,
    String? gst,
    double? taxPercent,
    String? paymentMethod,
    String? phone,
    String? waiterName,
    // New parameters for receipt generation
    String? orderNumber,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    List<Map<String, dynamic>>? kotItems,
    List<Map<String, dynamic>>? finalTaxes,
    String? tableName,
  }) async {
    try {
      if (!Hive.isAdapterRegistered(HiveOrderAdapter().typeId)) {
        Hive.registerAdapter(HiveOrderAdapter());
      }
      if (!Hive.isAdapterRegistered(HiveCartItemAdapter().typeId)) {
        Hive.registerAdapter(HiveCartItemAdapter());
      }

      // Debug logs for input
      debugPrint("Saving Offline Order...");
      debugPrint("OrderPayloadJson: $orderPayloadJson");
      debugPrint("Items raw: $items");

      // 🔄 UPDATE PRODUCT QUANTITIES BEFORE SAVING ORDER - MOVED TO TOP
      debugPrint("🔄 STEP 1: Updating product quantities...");
      await updateProductQuantities(items);
      debugPrint("✅ Product quantities updated successfully");

      // Generate unique ID
      final orderId = await HiveService.generateNextOfflineOrderIdString();
      debugPrint("Generated OrderId: $orderId");

      // Open the Hive box
      final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);

      // Convert items to HiveCartItem with better error handling
      List<HiveCartItem> hiveItems = [];

      for (int i = 0; i < items.length; i++) {
        try {
          final item = items[i];
          debugPrint("Processing item $i: ${item['name']} - Qty: ${item['quantity']}");

          final hiveItem = HiveCartItem.fromMap(item);
          hiveItems.add(hiveItem);
          debugPrint("Successfully converted item $i: ${hiveItem.name}");
        } catch (e, stackTrace) {
          debugPrint("❌ Error converting item $i: $e");

          // Create a fallback item to prevent complete failure
          final fallbackItem = HiveCartItem(
            product: items[i]['product']?.toString() ?? 'unknown',
            name: items[i]['name']?.toString() ?? 'Unknown Item',
            quantity: items[i]['quantity'] ?? 1,
            unitPrice: (items[i]['unitPrice'] ?? 0).toDouble(),
            subtotal: (items[i]['subtotal'] ?? 0).toDouble(),
            image: items[i]['image']?.toString() ?? '',
            selectedAddons: [],
          );
          hiveItems.add(fallbackItem);
        }
      }

      // Create HiveOrder object with all fields
      final order = HiveOrder(
        id: orderId,
        orderPayloadJson: orderPayloadJson,
        orderStatus: orderStatus,
        orderType: orderType,
        tableId: tableId,
        total: total,
        createdAt: DateTime.now(),
        isSynced: false,
        items: hiveItems,
        syncAction: syncAction,
        existingOrderId: existingOrderId,
        businessName: businessName,
        address: address,
        gst: gst,
        taxPercent: taxPercent,
        paymentMethod: paymentMethod,
        phone: phone,
        waiterName: waiterName,
        orderNumber: orderNumber,
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        kotItems: kotItems,
        finalTaxes: finalTaxes,
        tableName: tableName,
      );

      // Save to Hive
      await ordersBox.put(orderId, order);

      // Confirm save
      final saved = ordersBox.get(orderId);
      debugPrint("✅ Order saved successfully: ${saved?.id}");
      debugPrint("✅ Total orders in Hive: ${ordersBox.values.length}");

      return orderId;
    } catch (e, stackTrace) {
      debugPrint("❌ Critical error in saveOfflineOrder: $e");
      debugPrint("❌ Stack trace: $stackTrace");
      rethrow;
    }
  }

  static Future<List<HiveOrder>> getPendingSyncOrders() async {
    try {
      final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
      final pendingOrders =
      ordersBox.values.where((order) => order.isSynced == false).toList();

      print('Found ${pendingOrders.length} pending orders');
      return pendingOrders;
    } catch (e) {
      print('Error getting pending orders: $e');
      return [];
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

  // In HiveService, update the offline detection:
  static Future<bool> isLikelyOffline() async {
    try {
      final box = await Hive.openBox('app_state');
      final lastOnline = box.get('last_online');

      // If we never saved online timestamp, assume online
      if (lastOnline == null) return false;

      final lastOnlineTime = DateTime.fromMillisecondsSinceEpoch(lastOnline);
      final difference = DateTime.now().difference(lastOnlineTime);

      // Consider offline if no successful API call in last 10 minutes
      // (more reasonable than 5 minutes)
      return difference.inMinutes > 10;
    } catch (e) {
      // If any error, assume online to be safe
      return false;
    }
  }

  // Add this method to force offline mode for testing
  static Future<void> setOfflineMode(bool isOffline) async {
    final box = await Hive.openBox('app_state');
    if (isOffline) {
      // Set last online to 1 hour ago to force offline mode
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
      await box.put('last_online', oneHourAgo.millisecondsSinceEpoch);
    } else {
      // Set to current time to force online mode
      await box.put('last_online', DateTime.now().millisecondsSinceEpoch);
    }
  }

  // Sync Management
  static Future<void> syncPendingOrders(ApiProvider apiProvider) async {
    final pendingOrders = await getPendingSyncOrders();
    debugPrint("Pending orders to sync: ${pendingOrders.length}");

    for (var order in pendingOrders) {
      try {
        debugPrint("Syncing order ${order.id} (${order.syncAction})...");

        // Decode JSON and sanitize it before sending
        Map<String, dynamic> payload = {};
        try {
          payload = Map<String, dynamic>.from(
              jsonDecode(order.orderPayloadJson ?? '{}'));
        } catch (e) {
          debugPrint("⚠️ Error parsing orderPayloadJson for ${order.id}: $e");
          continue;
        }

        // 🧹 Remove unwanted fields for PARCEL orders
        if (payload['orderType'] == 'PARCEL') {
          payload.remove('tableNo');
          payload.remove('tableId');
          payload.remove('waiter');
        }

        // 🧹 Remove null or empty fields in general
        payload.removeWhere((key, value) =>
        value == null ||
            (value is String && value.trim().isEmpty) ||
            (value is List && value.isEmpty));

        final cleanedPayload = jsonEncode(payload);

        // 🔹 CREATE or UPDATE
        if (order.syncAction == 'CREATE') {
          final response =
          await apiProvider.postGenerateOrderAPI(cleanedPayload);
          debugPrint("📤 CREATE payload: $cleanedPayload");
          debugPrint("📥 CREATE response: ${response.toJson()}");

          if (response.order != null) {
            await markOrderAsSynced(order.id!);
            debugPrint("✅ Order created & synced");
          } else {
            debugPrint("❌ Create failed for order ${order.id}");
          }
        } else if (order.syncAction == 'UPDATE') {
          if (order.existingOrderId == null) {
            debugPrint(
                "❌ Missing existingOrderId for UPDATE order: ${order.id}");
            continue;
          }

          final response = await apiProvider.updateGenerateOrderAPI(
            cleanedPayload,
            order.existingOrderId!,
          );

          debugPrint("📤 UPDATE payload: $cleanedPayload");
          debugPrint("📥 UPDATE response: ${response.toJson()}");

          if (response.order != null) {
            await markOrderAsSynced(order.id!);
            debugPrint("✅ Order updated & synced");
          } else {
            debugPrint("❌ Update failed for order ${order.id}");
          }
        }
      } catch (e) {
        debugPrint("❌ Failed to sync order ${order.id}: $e");
      }
    }
  }

  static Future<void> markOrderAsSynced(String orderId) async {
    final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
    debugPrint(
        "Unsynced orders left: ${ordersBox.values.where((o) => o.isSynced == false).length}");
    final order = ordersBox.get(orderId);
    if (order != null) {
      order.isSynced = true;
      await ordersBox.put(orderId, order);
      debugPrint("✅ Order $orderId marked as synced in Hive");
    }
  }

  // Check if device is offline based on last successful API call
  static Future<void> saveLastOnlineTimestamp() async {
    final box = await Hive.openBox('app_state');
    await box.put('last_online', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> fixHiveTypeIssue() async {
    try {
      debugPrint("🔧 Fixing Hive type mismatch issue...");

      // Close all boxes first
      await closeBox();

      // Delete existing boxes to clear corrupted data
      await Hive.deleteBoxFromDisk(CART_BOX);
      await Hive.deleteBoxFromDisk(ORDERS_BOX);
      await Hive.deleteBoxFromDisk(BILLING_SESSION_BOX);
      await Hive.deleteBoxFromDisk(SYNC_QUEUE_BOX);
      await Hive.deleteBoxFromDisk('pendingActions');
      await Hive.deleteBoxFromDisk('app_state');
      await Hive.deleteBoxFromDisk(MASTER_PRODUCTS_BOX);

      debugPrint("✅ Cleared all existing Hive data");

      // Re-register adapters with correct type IDs
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HiveBillingSessionAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HiveCartItemAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(HiveOrderAdapter());
      }

      debugPrint("✅ Re-registered all adapters");

      // Test opening boxes
      final testCartBox = await Hive.openBox<HiveCartItem>(CART_BOX);
      final testOrderBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
      final testBillingBox =
      await Hive.openBox<HiveBillingSession>(BILLING_SESSION_BOX);

      await testCartBox.close();
      await testOrderBox.close();
      await testBillingBox.close();

      debugPrint("✅ Hive type issue fixed successfully!");
    } catch (e) {
      debugPrint("❌ Error fixing Hive issue: $e");
      rethrow;
    }
  }
  // ==================== LAST ONLINE / OFFLINE ID MANAGEMENT ====================

  static const String LAST_ONLINE_ORDER_ID_BOX = 'last_online_order_id_box';

  /// Save the last online order ID as raw string (ex: 'ORD-00123' or '1250').
  /// Internally extracts trailing number, prefix, and numeric length to allow
  /// generating next sequential offline IDs preserving prefix/padding.
  static Future<void> saveLastOnlineOrderIdRaw(String orderIdRaw) async {
    final box = await Hive.openBox(LAST_ONLINE_ORDER_ID_BOX);

    await box.put('last_online_order_id_raw', orderIdRaw);

    final match = RegExp(r'(\d+)$').firstMatch(orderIdRaw);
    if (match != null) {
      final numericStr = match.group(1)!;
      final numeric = int.tryParse(numericStr) ?? 0;
      final prefix =
      orderIdRaw.substring(0, orderIdRaw.length - numericStr.length);
      await box.put('last_online_order_id_numeric', numeric);
      await box.put('last_online_order_id_numeric_len', numericStr.length);
      await box.put('last_online_order_id_prefix', prefix);
    } else {
      // No trailing number: treat full raw as prefix and start numbering from 0
      await box.put('last_online_order_id_numeric', 0);
      await box.put('last_online_order_id_numeric_len', 0);
      await box.put('last_online_order_id_prefix', '${orderIdRaw}-');
    }
  }

  /// Get the last online order id raw string (or null if none)
  static Future<String?> getLastOnlineOrderIdRaw() async {
    final box = await Hive.openBox(LAST_ONLINE_ORDER_ID_BOX);
    final raw = box.get('last_online_order_id_raw');
    if (raw == null) return null;
    return raw.toString();
  }

  /// Get the numeric value stored (0 if none)
  static Future<int> getLastOnlineOrderIdNumeric() async {
    final box = await Hive.openBox(LAST_ONLINE_ORDER_ID_BOX);
    final val = box.get('last_online_order_id_numeric', defaultValue: 0);
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  /// Generate next offline order id preserving prefix and padding if possible.
  /// Example:
  ///   last raw = "ORD-00123" -> returns "ORD-00124"
  ///   last raw = "1250" -> returns "1251"
  ///   none saved -> returns "OFF-0001"
  static Future<String> generateNextOfflineOrderIdString(
      {String defaultPrefix = 'OFF-', int defaultPadding = 4}) async {
    final box = await Hive.openBox(LAST_ONLINE_ORDER_ID_BOX);
    final rawDynamic = box.get('last_online_order_id_raw');
    final prefixDynamic =
    box.get('last_online_order_id_prefix', defaultValue: defaultPrefix);
    final numericDynamic =
    box.get('last_online_order_id_numeric', defaultValue: 0);
    final numericLenDynamic = box.get('last_online_order_id_numeric_len',
        defaultValue: defaultPadding);

    String prefix = prefixDynamic?.toString() ?? defaultPrefix;
    int numeric = (numericDynamic is int)
        ? numericDynamic
        : int.tryParse(numericDynamic?.toString() ?? '') ?? 0;
    int numericLen = (numericLenDynamic is int)
        ? numericLenDynamic
        : int.tryParse(numericLenDynamic?.toString() ?? '') ?? defaultPadding;

    if (rawDynamic == null) {
      // First offline id when nothing is saved yet
      final newNumeric = 1;
      final id = '$prefix${newNumeric.toString().padLeft(numericLen, '0')}';
      await box.put('last_online_order_id_raw', id);
      await box.put('last_online_order_id_numeric', newNumeric);
      await box.put('last_online_order_id_numeric_len', numericLen);
      await box.put('last_online_order_id_prefix', prefix);
      return id;
    } else {
      numeric = numeric + 1;
      final id = '$prefix${numeric.toString().padLeft(numericLen, '0')}';
      // persist new values
      await box.put('last_online_order_id_raw', id);
      await box.put('last_online_order_id_numeric', numeric);
      await box.put('last_online_order_id_numeric_len', numericLen);
      await box.put('last_online_order_id_prefix', prefix);
      return id;
    }
  }

  /// Generate next offline order numeric (returns int) and updates stored numeric and raw.
  static Future<int> generateNextOfflineOrderIdInt(
      {String defaultPrefix = 'OFF-', int defaultPadding = 4}) async {
    final box = await Hive.openBox(LAST_ONLINE_ORDER_ID_BOX);
    final numericDynamic =
    box.get('last_online_order_id_numeric', defaultValue: 0);
    final prefixDynamic =
    box.get('last_online_order_id_prefix', defaultValue: defaultPrefix);
    final numericLenDynamic = box.get('last_online_order_id_numeric_len',
        defaultValue: defaultPadding);

    int numeric = (numericDynamic is int)
        ? numericDynamic
        : int.tryParse(numericDynamic?.toString() ?? '') ?? 0;
    final prefix = prefixDynamic?.toString() ?? defaultPrefix;
    final numericLen = (numericLenDynamic is int)
        ? numericLenDynamic
        : int.tryParse(numericLenDynamic?.toString() ?? '') ?? defaultPadding;

    numeric = numeric + 1;
    final raw = '$prefix${numeric.toString().padLeft(numericLen, '0')}';

    await box.put('last_online_order_id_numeric', numeric);
    await box.put('last_online_order_id_raw', raw);
    await box.put('last_online_order_id_numeric_len', numericLen);
    await box.put('last_online_order_id_prefix', prefix);

    return numeric;
  }

  /// Reset the stored last-online order tracking
  static Future<void> resetLastOnlineOrderId() async {
    final box = await Hive.openBox(LAST_ONLINE_ORDER_ID_BOX);
    await box.delete('last_online_order_id_raw');
    await box.delete('last_online_order_id_numeric');
    await box.delete('last_online_order_id_numeric_len');
    await box.delete('last_online_order_id_prefix');
    debugPrint("🔄 Reset last online order id tracking");
  }
}