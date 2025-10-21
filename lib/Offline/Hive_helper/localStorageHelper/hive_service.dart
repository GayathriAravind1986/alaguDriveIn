// hive_service.dart
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:simple/Api/apiProvider.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_billing_session_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_cart_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_order_model.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/product_model.dart';
import 'package:uuid/uuid.dart';

class HiveService {
  static const String CART_BOX = 'cart_items';
  static const String ORDERS_BOX = 'orders';
  static const String BILLING_SESSION_BOX = 'billing_session';
  static const String SYNC_QUEUE_BOX = 'sync_queue';
  static const String orderTypeBoxName = 'order_type';
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
  // static Future<void> saveCartItems(
  //     List<Map<String, dynamic>> billingItems) async {
  //   final cartBox = await Hive.openBox<HiveCartItem>(CART_BOX);
  //   await cartBox.clear(); // Clear existing cart
  //
  //   for (var item in billingItems) {
  //     final hiveItem = HiveCartItem.fromMap(item);
  //     await cartBox.add(hiveItem);
  //   }
  // }

  // static Future<void> saveCartItems(
  //   List<Map<String, dynamic>> billingItems, [
  //   String? categoryId,
  // ]) async {
  //   final cartBox = await Hive.openBox<HiveCartItem>(CART_BOX);
  //   await cartBox.clear();
  //
  //   if (categoryId != null) {
  //     debugPrint("🟢 Offline SaveCartItems for category: $categoryId");
  //
  //     final productBox =
  //         await Hive.openBox<HiveProduct>('products_$categoryId');
  //
  //     for (var item in billingItems) {
  //       final productId = item['_id'] ?? item['id'];
  //       final product = productBox.values.firstWhere(
  //         (p) => p.id == productId,
  //         orElse: () => HiveProduct(
  //           id: productId,
  //           name: item['name'] ?? 'Unknown Product',
  //           basePrice: (item['basePrice'] ?? 0.0).toDouble(),
  //           parcelPrice: (item['parcelPrice'] ?? 0.0).toDouble(),
  //           acPrice: (item['acPrice'] ?? 0.0).toDouble(),
  //           swiggyPrice: (item['swiggyPrice'] ?? 0.0).toDouble(),
  //           hdPrice: (item['hdPrice'] ?? 0.0).toDouble(),
  //         ),
  //       );
  //       debugPrint('Product: ${product.name} | '
  //           'Base: ${product.basePrice}, '
  //           'Parcel: ${product.parcelPrice}, '
  //           'AC: ${product.acPrice}, '
  //           'Swiggy: ${product.swiggyPrice}, '
  //           'HD: ${product.hdPrice}');
  //       final hiveItem = HiveCartItem(
  //         id: product.id,
  //         product: product.id,
  //         name: product.name,
  //         image: product.image,
  //         basePrice: product.basePrice ?? 0.0,
  //         parcelPrice: product.parcelPrice ?? 0.0,
  //         acPrice: product.acPrice ?? 0.0,
  //         swiggyPrice: product.swiggyPrice ?? 0.0,
  //         hdPrice: product.hdPrice ?? 0.0,
  //         quantity: item['quantity'] ?? 1,
  //         selectedAddons: item['selectedAddons']?.cast<Map<String, dynamic>>(),
  //       );
  //
  //       debugPrint(
  //           "✅ Saved cart item: ${hiveItem.name} | Base: ${hiveItem.basePrice}, AC: ${hiveItem.acPrice}, Parcel: ${hiveItem.parcelPrice}");
  //
  //       await cartBox.add(hiveItem);
  //     }
  //   } else {
  //     // ONLINE MODE
  //     debugPrint("🔵 Online SaveCartItems");
  //     for (var item in billingItems) {
  //       final hiveItem = HiveCartItem.fromMap(item);
  //       await cartBox.add(hiveItem);
  //     }
  //   }
  // }
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

        debugPrint("📦 Processing item: ${item['name']}");
        debugPrint("   Looking for product ID: $productId");

        // Find product in Hive
        HiveProduct? product;
        try {
          product = productBox.values.firstWhere(
            (p) => p.id == productId,
          );
          debugPrint("   ✅ Found product in Hive: ${product.name}");
        } catch (e) {
          debugPrint("   ⚠️ Product not found in Hive, creating default");
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

        // Log product prices
        debugPrint("   💰 Product Prices:");
        debugPrint("      Base: ${product.basePrice}");
        debugPrint("      AC: ${product.acPrice}");
        debugPrint("      Parcel: ${product.parcelPrice}");
        debugPrint("      Swiggy: ${product.swiggyPrice}");
        debugPrint("      HD: ${product.hdPrice}");

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

        debugPrint("   ✅ Created HiveCartItem:");
        debugPrint("      Name: ${hiveItem.name}");
        debugPrint("      Base: ${hiveItem.basePrice}");
        debugPrint("      AC: ${hiveItem.acPrice}");
        debugPrint("      Parcel: ${hiveItem.parcelPrice}");
        debugPrint("      Swiggy: ${hiveItem.swiggyPrice}");
        debugPrint("      HD: ${hiveItem.hdPrice}");

        await cartBox.add(hiveItem);
      }
    } else {
      // ONLINE MODE - Prices should already be in the map
      debugPrint("🔵 Online SaveCartItems");
      for (var item in billingItems) {
        debugPrint("📦 Online item: ${item['name']}");
        debugPrint("   Incoming data: $item");

        final hiveItem = HiveCartItem.fromMap(item);

        debugPrint("   ✅ Converted to HiveCartItem:");
        debugPrint("      Base: ${hiveItem.basePrice}");
        debugPrint("      AC: ${hiveItem.acPrice}");
        debugPrint("      Parcel: ${hiveItem.parcelPrice}");
        debugPrint("      Swiggy: ${hiveItem.swiggyPrice}");
        debugPrint("      HD: ${hiveItem.hdPrice}");

        await cartBox.add(hiveItem);
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

  // static HiveBillingSession calculateBillingTotals(
  //   List<Map<String, dynamic>> billingItems,
  //   bool isDiscount, {
  //   String? orderType,
  // }) {
  //   double subtotal = 0.0;
  //   double totalTax = 0.0;
  //   double totalDiscount = 0.0;
  //
  //   List<HiveCartItem> hiveItems = [];
  //
  //   for (var item in billingItems) {
  //     final hiveItem = HiveCartItem.fromMap(item);
  //
  //     // ✅ Use built-in method that picks correct price
  //     double itemPrice = hiveItem.getPriceByOrderType(orderType);
  //     int itemQty = hiveItem.quantity ?? 1;
  //
  //     // 🧩 Calculate addon total
  //     double addonTotal = 0.0;
  //     if (hiveItem.selectedAddons != null) {
  //       for (var addon in hiveItem.selectedAddons!) {
  //         if (!(addon['isFree'] ?? false)) {
  //           double addonPrice = (addon['price'] ?? 0.0).toDouble();
  //           int addonQty = addon['quantity'] ?? 0;
  //           addonTotal += (addonPrice * addonQty);
  //         }
  //       }
  //     }
  //
  //     // 🧾 Calculate item subtotal (base price + addons) * quantity
  //     double itemSubtotal = (itemPrice + addonTotal) * itemQty;
  //
  //     // Update hiveItem
  //     hiveItem.unitPrice = itemPrice;
  //     hiveItem.basePrice = itemPrice;
  //     hiveItem.subtotal = itemSubtotal;
  //
  //     // 💰 Calculate tax (18%)
  //     double itemTax = itemSubtotal * 0.18;
  //     hiveItem.taxPrice = itemTax;
  //
  //     // 💵 Total per item
  //     hiveItem.totalPrice = itemSubtotal + itemTax;
  //
  //     subtotal += itemSubtotal;
  //     totalTax += itemTax;
  //
  //     hiveItems.add(hiveItem);
  //   }
  //
  //   // 🎁 Apply discount if needed
  //   if (isDiscount) {
  //     totalDiscount = subtotal * 0.1; // 10%
  //     subtotal -= totalDiscount;
  //   }
  //
  //   double total = subtotal + totalTax;
  //
  //   return HiveBillingSession(
  //     isDiscountApplied: isDiscount,
  //     subtotal: subtotal,
  //     totalTax: totalTax,
  //     total: total,
  //     totalDiscount: totalDiscount,
  //     items: hiveItems,
  //     orderType: orderType,
  //     lastUpdated: DateTime.now(),
  //   );
  // }
  static Future<HiveBillingSession> calculateBillingTotals(
    List<Map<String, dynamic>> billingItems,
    bool isDiscount, {
    String? orderType,
  }) async {
    debugPrint("🧮 calculateBillingTotals called");
    debugPrint("   Order Type: $orderType");
    debugPrint("   Items count: ${billingItems.length}");
    debugPrint("   Discount applied: $isDiscount");

    double subtotal = 0.0;
    double totalTax = 0.0;
    double totalDiscount = 0.0;

    List<HiveCartItem> hiveItems = [];

    for (int i = 0; i < billingItems.length; i++) {
      var item = billingItems[i];
      debugPrint("\n📦 Processing item ${i + 1}/${billingItems.length}");
      debugPrint("   Item data: $item");
      final productId = item['id']?.toString() ??
          item['product']?.toString() ??
          item['productId']?.toString() ??
          item['_id']?.toString();
      final productBox = await Hive.openBox<HiveProduct>('products');
      final hiveProduct = productBox.values.firstWhere(
        (p) => p.id == productId,
        orElse: () => HiveProduct(
          id: productId,
          name: item['name'] ?? 'Unknown Product',
          basePrice: (item['basePrice'] ?? 0.0).toDouble(),
          parcelPrice: (item['parcelPrice'] ?? 0.0).toDouble(),
          acPrice: (item['acPrice'] ?? 0.0).toDouble(),
          swiggyPrice: (item['swiggyPrice'] ?? 0.0).toDouble(),
          hdPrice: (item['hdPrice'] ?? 0.0).toDouble(),
        ),
      );
      final mergedItem = {
        ...item,
        'basePrice': item['basePrice'] ?? hiveProduct.basePrice,
        'acPrice': item['acPrice'] ?? hiveProduct.acPrice,
        'parcelPrice': item['parcelPrice'] ?? hiveProduct.parcelPrice,
        'swiggyPrice': item['swiggyPrice'] ?? hiveProduct.swiggyPrice,
        'hdPrice': item['hdPrice'] ?? hiveProduct.hdPrice,
      };
      final hiveItem = HiveCartItem.fromMap(mergedItem);

      debugPrint("   After fromMap:");
      debugPrint("      Name: ${hiveItem.name}");
      debugPrint("      Base: ${hiveItem.basePrice}");
      debugPrint("      AC: ${hiveItem.acPrice}");
      debugPrint("      Parcel: ${hiveItem.parcelPrice}");
      debugPrint("      Swiggy: ${hiveItem.swiggyPrice}");
      debugPrint("      HD: ${hiveItem.hdPrice}");

      // ✅ Get correct price based on order type
      double itemPrice = hiveItem.getPriceByOrderType(orderType);
      int itemQty = hiveItem.quantity ?? 1;

      debugPrint(
          "   📊 Selected price for order type '$orderType': $itemPrice");
      debugPrint("   📊 Quantity: $itemQty");

      // 🧩 Calculate addon total
      double addonTotal = 0.0;
      if (hiveItem.selectedAddons != null) {
        debugPrint("   🎁 Processing addons:");
        for (var addon in hiveItem.selectedAddons!) {
          if (!(addon['isFree'] ?? false)) {
            double addonPrice = (addon['price'] ?? 0.0).toDouble();
            int addonQty = addon['quantity'] ?? 0;
            double addonSubtotal = addonPrice * addonQty;
            addonTotal += addonSubtotal;
            debugPrint(
                "      - ${addon['name']}: ₹$addonPrice x $addonQty = ₹$addonSubtotal");
          }
        }
        debugPrint("   🎁 Total addons: ₹$addonTotal");
      }

      // 🧾 Calculate item subtotal (base price + addons) * quantity
      double itemSubtotal = (itemPrice + addonTotal) * itemQty;
      debugPrint(
          "   💵 Item subtotal: (₹$itemPrice + ₹$addonTotal) x $itemQty = ₹$itemSubtotal");

      // Update hiveItem with calculated values
      hiveItem.unitPrice = itemPrice;
      hiveItem.basePrice = itemPrice;
      hiveItem.subtotal = itemSubtotal;

      // 💰 Calculate tax (18%)
      double itemTax = itemSubtotal * 0.18;
      hiveItem.taxPrice = itemTax;
      debugPrint("   💰 Tax (18%): ₹$itemTax");

      // 💵 Total per item
      hiveItem.totalPrice = itemSubtotal + itemTax;
      debugPrint("   💵 Item total: ₹${hiveItem.totalPrice}");

      subtotal += itemSubtotal;
      totalTax += itemTax;

      hiveItems.add(hiveItem);
    }

    debugPrint("\n📊 Billing Summary:");
    debugPrint("   Subtotal: ₹$subtotal");

    // 🎁 Apply discount if needed
    if (isDiscount) {
      totalDiscount = subtotal * 0.1; // 10%
      subtotal -= totalDiscount;
      debugPrint("   Discount (10%): -₹$totalDiscount");
      debugPrint("   Subtotal after discount: ₹$subtotal");
    }

    debugPrint("   Tax (18%): ₹$totalTax");
    double total = subtotal + totalTax;
    debugPrint("   TOTAL: ₹$total");

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

      // Open the Hive box
      final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
      print("Orders saved in Hive before: ${ordersBox.values.length}");

      // Generate unique ID
      // inside saveOfflineOrder(...)
      final orderId = await HiveService.generateNextOfflineOrderIdString();
// then use orderId as the Hive key

      // Debug logs for input
      print("Saving Offline Order...");
      print("OrderId: $orderId");
      print("OrderPayloadJson type: ${orderPayloadJson.runtimeType}");
      print("OrderPayloadJson: $orderPayloadJson");
      print("Items raw: $items");

      // Convert items to HiveCartItem with better error handling
      List<HiveCartItem> hiveItems = [];

      for (int i = 0; i < items.length; i++) {
        try {
          final item = items[i];
          print("Processing item $i: $item");
          print("Item keys: ${item.keys.toList()}");

          // Validate required fields before conversion
          if (item['name'] == null || item['name'].toString().isEmpty) {
            print("Warning: Item $i has empty name, setting default");
          }

          final hiveItem = HiveCartItem.fromMap(item);
          hiveItems.add(hiveItem);
          print("Successfully converted item $i: $hiveItem");
        } catch (e, stackTrace) {
          print("❌ Error converting item $i to HiveCartItem: ${items[i]}");
          print("❌ Error type: ${e.runtimeType}");
          print("❌ Error message: $e");
          print("❌ Stack trace: $stackTrace");

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
          print("✅ Created fallback item: $fallbackItem");
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
        // New fields
        orderNumber: orderNumber,
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        kotItems: kotItems,
        finalTaxes: finalTaxes,
        tableName: tableName,
      );
      // String _orderBox = 'orders_today_box';
      // final box = await Hive.openBox(_orderBox);
      // box.put('orders_today',order);
      // Save to Hive
      await ordersBox.put(orderId, order);

      // await ordersBox.put(orderId, order);

      // Confirm save
      final saved = ordersBox.get(orderId);
      print("Orders saved in Hive after: ${ordersBox.values.length}");
      print("✅ Order saved successfully: ${saved?.id}");
      print("✅ Order saved successfully: ${saved?.tableName}");

      return orderId;
    } catch (e, stackTrace) {
      print("❌ Critical error in saveOfflineOrder: $e");
      print("❌ Stack trace: $stackTrace");
      rethrow;
    }
  }

  static Future<List<HiveOrder>> getPendingSyncOrders() async {
    final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
    return ordersBox.values.where((order) => order.isSynced == false).toList();
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
    print("Pending orders to sync: ${pendingOrders.length}");

    for (var order in pendingOrders) {
      try {
        print("Syncing order ${order.id} (${order.syncAction})...");

        // Decode JSON and sanitize it before sending
        Map<String, dynamic> payload = {};
        try {
          payload = Map<String, dynamic>.from(
              jsonDecode(order.orderPayloadJson ?? '{}'));
        } catch (e) {
          print("⚠️ Error parsing orderPayloadJson for ${order.id}: $e");
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
          print("📤 CREATE payload: $cleanedPayload");
          print("📥 CREATE response: ${response.toJson()}");

          if (response.order != null) {
            await markOrderAsSynced(order.id!);
            print("✅ Order created & synced");
          } else {
            print("❌ Create failed for order ${order.id}");
          }
        } else if (order.syncAction == 'UPDATE') {
          if (order.existingOrderId == null) {
            print("❌ Missing existingOrderId for UPDATE order: ${order.id}");
            continue;
          }

          final response = await apiProvider.updateGenerateOrderAPI(
            cleanedPayload,
            order.existingOrderId!,
          );

          print("📤 UPDATE payload: $cleanedPayload");
          print("📥 UPDATE response: ${response.toJson()}");

          if (response.order != null) {
            await markOrderAsSynced(order.id!);
            print("✅ Order updated & synced");
          } else {
            print("❌ Update failed for order ${order.id}");
          }
        }
      } catch (e) {
        print("❌ Failed to sync order ${order.id}: $e");
      }
    }
  }

  static Future<void> markOrderAsSynced(String orderId) async {
    final ordersBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
    print(
        "Unsynced orders left: ${ordersBox.values.where((o) => o.isSynced == false).length}");
    final order = ordersBox.get(orderId);
    if (order != null) {
      order.isSynced = true;
      await ordersBox.put(orderId, order);
      print("✅ Order $orderId marked as synced in Hive");
    }
  }

  // Check if device is offline based on last successful API call
  static Future<void> saveLastOnlineTimestamp() async {
    final box = await Hive.openBox('app_state');
    await box.put('last_online', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> fixHiveTypeIssue() async {
    try {
      print("🔧 Fixing Hive type mismatch issue...");

      // Close all boxes first
      await closeBox();

      // Delete existing boxes to clear corrupted data
      await Hive.deleteBoxFromDisk(CART_BOX);
      await Hive.deleteBoxFromDisk(ORDERS_BOX);
      await Hive.deleteBoxFromDisk(BILLING_SESSION_BOX);
      await Hive.deleteBoxFromDisk(SYNC_QUEUE_BOX);
      await Hive.deleteBoxFromDisk('pendingActions');
      await Hive.deleteBoxFromDisk('app_state');

      print("✅ Cleared all existing Hive data");

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

      print("✅ Re-registered all adapters");

      // Test opening boxes
      final testCartBox = await Hive.openBox<HiveCartItem>(CART_BOX);
      final testOrderBox = await Hive.openBox<HiveOrder>(ORDERS_BOX);
      final testBillingBox =
          await Hive.openBox<HiveBillingSession>(BILLING_SESSION_BOX);

      await testCartBox.close();
      await testOrderBox.close();
      await testBillingBox.close();

      print("✅ Hive type issue fixed successfully!");
    } catch (e) {
      print("❌ Error fixing Hive issue: $e");
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
    print("🔄 Reset last online order id tracking");
  }
}
