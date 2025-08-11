import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:simple/Offline/Database_helper/DataBaseHelper.dart';
import 'package:simple/Offline/Network_status/NetworkStatusService.dart';

// class OfflineSyncService {
//   static final OfflineSyncService _instance = OfflineSyncService._internal();
//   factory OfflineSyncService() => _instance;
//   OfflineSyncService._internal();
//
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   final NetworkManager _networkManager = NetworkManager();
//
//   Timer? _syncTimer;
//   bool _isSyncing = false;
//
//   // Initialize offline sync service
//   void initialize() {
//     // Listen to network changes and sync when online
//     _networkManager.connectionStream.listen((result) {
//       if (_networkManager.isOnline && !_isSyncing) {
//         syncPendingOrders();
//       }
//     });
//
//     // Start periodic sync every 5 minutes when online
//     _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
//       if (_networkManager.isOnline && !_isSyncing) {
//         syncPendingOrders();
//       }
//     });
//   }
//
//   // Cache API response data locally
//   Future<void> cacheCategories(List<dynamic> categories) async {
//     try {
//       List<Map<String, dynamic>> categoryMaps = categories.map((category) {
//         return {
//           'id': category['id']?.toString() ?? '',
//           'name': category['name']?.toString() ?? '',
//           'image': category['image']?.toString() ?? '',
//         };
//       }).toList();
//
//       await _dbHelper.insertMultipleCategories(categoryMaps);
//       if (kDebugMode) {
//         print('Categories cached successfully: ${categoryMaps.length} items');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error caching categories: $e');
//       }
//     }
//   }
//
//   Future<void> cacheProducts(List<dynamic> products) async {
//     try {
//       List<Map<String, dynamic>> productMaps = products.map((product) {
//         return {
//           'id': product['id']?.toString() ?? '',
//           'name': product['name']?.toString() ?? '',
//           'image': product['image']?.toString() ?? '',
//           'basePrice': product['basePrice']?.toDouble() ?? 0.0,
//           'availableQuantity': product['availableQuantity']?.toInt() ?? 0,
//           'categoryId': product['categoryId']?.toString() ?? '',
//           'addons': product['addons'] ?? [],
//           'stockMaintenance': product['stockMaintenance'] == true ? 1 : 0,
//         };
//       }).toList();
//
//       await _dbHelper.insertMultipleProducts(productMaps);
//       if (kDebugMode) {
//         print('Products cached successfully: ${productMaps.length} items');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error caching products: $e');
//       }
//     }
//   }
//
//   Future<void> cacheTables(List<dynamic> tables) async {
//     try {
//       List<Map<String, dynamic>> tableMaps = tables.map((table) {
//         return {
//           'id': table['id']?.toString() ?? '',
//           'name': table['name']?.toString() ?? '',
//           'status': table['status']?.toString() ?? 'AVAILABLE',
//         };
//       }).toList();
//
//       await _dbHelper.insertMultipleTables(tableMaps);
//       if (kDebugMode) {
//         print('Tables cached successfully: ${tableMaps.length} items');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error caching tables: $e');
//       }
//     }
//   }
//
//   // Get cached data
//   Future<List<Map<String, dynamic>>> getCachedCategories() async {
//     return await _dbHelper.getCategories();
//   }
//
//   Future<List<Map<String, dynamic>>> getCachedProducts(
//       [String? categoryId]) async {
//     return await _dbHelper.getProducts(categoryId);
//   }
//
//   Future<List<Map<String, dynamic>>> getCachedTables() async {
//     return await _dbHelper.getTables();
//   }
//
//   // Cart persistence
//   Future<void> saveBillingItemsLocally(
//       List<Map<String, dynamic>> billingItems) async {
//     await _dbHelper.saveBillingItems(billingItems);
//   }
//
//   Future<List<Map<String, dynamic>>> getLocalBillingItems() async {
//     return await _dbHelper.getBillingItems();
//   }
//
//   Future<void> clearLocalBillingItems() async {
//     await _dbHelper.clearBillingItems();
//   }
//
//   // Offline orders handling
//   Future<String> saveOrderLocally(Map<String, dynamic> orderData) async {
//     if (_networkManager.isOnline) {
//       // If online, you should still call your API
//       throw Exception('Device is online, use API instead');
//     }
//
//     await _dbHelper.saveOfflineOrder(orderData);
//     return 'Order saved locally. Will sync when online.';
//   }
//
//   // Sync pending orders when network becomes available
//   Future<void> syncPendingOrders() async {
//     if (_isSyncing || !_networkManager.isOnline) return;
//
//     _isSyncing = true;
//
//     try {
//       final pendingOrders = await _dbHelper.getPendingSyncOrders();
//
//       for (var order in pendingOrders) {
//         try {
//           // Here you would call your actual API to sync the order
//           // Example: await _apiService.createOrder(jsonDecode(order['orderData']));
//
//           // For now, just mark as synced after successful API call
//           await _dbHelper.markOrderAsSynced(order['id']);
//
//           if (kDebugMode) {
//             print('Order synced successfully: ${order['id']}');
//           }
//         } catch (e) {
//           if (kDebugMode) {
//             print('Failed to sync order ${order['id']}: $e');
//           }
//           // Don't mark as synced if API call fails
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error during sync: $e');
//       }
//     } finally {
//       _isSyncing = false;
//     }
//   }
//
//   // Check if there are pending orders to sync
//   Future<int> getPendingOrdersCount() async {
//     final orders = await _dbHelper.getPendingSyncOrders();
//     return orders.length;
//   }
//
//   // Clear all cached data
//   Future<void> clearAllCachedData() async {
//     await _dbHelper.clearAllData();
//   }
//
//   void dispose() {
//     _syncTimer?.cancel();
//   }
// }

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  // Keep your existing database and network dependencies
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NetworkManager _networkManager = NetworkManager();

  Timer? _syncTimer;
  bool _isSyncing = false;

  // SharedPreferences keys for caching
  static const String _categoriesKey = 'cached_categories';
  static const String _productsKey = 'cached_products';
  static const String _cartKey = 'cached_cart';
  static const String _tablesKey = 'cached_tables';

  // Initialize offline sync service
  void initialize() {
    // Listen to network changes and sync when online
    _networkManager.connectionStream.listen((result) {
      if (_networkManager.isOnline && !_isSyncing) {
        syncPendingOrders();
      }
    });

    // Start periodic sync every 5 minutes when online
    _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (_networkManager.isOnline && !_isSyncing) {
        syncPendingOrders();
      }
    });
  }

  // ===========================================
  // EXISTING ORDER OPERATIONS (KEEP AS IS)
  // ===========================================

  // Cart persistence using Database (existing functionality)
  Future<void> saveBillingItemsLocally(
      List<Map<String, dynamic>> billingItems) async {
    await _dbHelper.saveBillingItems(billingItems);
  }

  Future<List<Map<String, dynamic>>> getLocalBillingItems() async {
    return await _dbHelper.getBillingItems();
  }

  Future<void> clearLocalBillingItems() async {
    await _dbHelper.clearBillingItems();
  }

  // Offline orders handling (existing functionality)
  Future<String> saveOrderLocally(Map<String, dynamic> orderData) async {
    if (_networkManager.isOnline) {
      // If online, you should still call your API
      throw Exception('Device is online, use API instead');
    }

    await _dbHelper.saveOfflineOrder(orderData);
    return 'Order saved locally. Will sync when online.';
  }

  // Sync pending orders when network becomes available
  Future<void> syncPendingOrders() async {
    if (_isSyncing || !_networkManager.isOnline) return;

    _isSyncing = true;

    try {
      final pendingOrders = await _dbHelper.getPendingSyncOrders();

      for (var order in pendingOrders) {
        try {
          // Here you would call your actual API to sync the order
          // Example: await _apiService.createOrder(jsonDecode(order['orderData']));

          // For now, just mark as synced after successful API call
          await _dbHelper.markOrderAsSynced(order['id']);

          if (kDebugMode) {
            print('Order synced successfully: ${order['id']}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync order ${order['id']}: $e');
          }
          // Don't mark as synced if API call fails
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during sync: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  // Check if there are pending orders to sync
  Future<int> getPendingOrdersCount() async {
    final orders = await _dbHelper.getPendingSyncOrders();
    return orders.length;
  }

  // ===========================================
  // NEW CACHING FUNCTIONALITY
  // ===========================================

  // Cache API response data using both Database AND SharedPreferences
  Future<void> cacheCategories(List<dynamic> categories) async {
    try {
      // Store in database (existing functionality)
      List<Map<String, dynamic>> categoryMaps = categories.map((category) {
        return {
          'id': category['id']?.toString() ?? '',
          'name': category['name']?.toString() ?? '',
          'image': category['image']?.toString() ?? '',
        };
      }).toList();

      await _dbHelper.insertMultipleCategories(categoryMaps);

      // ALSO store in SharedPreferences for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_categoriesKey, jsonEncode(categoryMaps));

      if (kDebugMode) {
        print('Categories cached successfully: ${categoryMaps.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching categories: $e');
      }
    }
  }

  Future<void> cacheProducts(List<dynamic> products,
      {String? categoryId}) async {
    try {
      // Store in database (existing functionality)
      List<Map<String, dynamic>> productMaps = products.map((product) {
        return {
          'id': product['id']?.toString() ?? '',
          'name': product['name']?.toString() ?? '',
          'image': product['image']?.toString() ?? '',
          'basePrice': product['basePrice']?.toDouble() ?? 0.0,
          'availableQuantity': product['availableQuantity']?.toInt() ?? 0,
          'categoryId': product['categoryId']?.toString() ?? categoryId ?? '',
          'addons': product['addons'] ?? [],
          'stockMaintenance': product['stockMaintenance'] == true ? 1 : 0,
        };
      }).toList();

      await _dbHelper.insertMultipleProducts(productMaps);

      // ALSO store in SharedPreferences for quick access
      if (categoryId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            '${_productsKey}_$categoryId', jsonEncode(productMaps));
      }

      if (kDebugMode) {
        print('Products cached successfully: ${productMaps.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching products: $e');
      }
    }
  }

  Future<void> cacheTables(List<dynamic> tables) async {
    try {
      // Store in database (existing functionality)
      List<Map<String, dynamic>> tableMaps = tables.map((table) {
        return {
          'id': table['id']?.toString() ?? '',
          'name': table['name']?.toString() ?? '',
          'status': table['status']?.toString() ?? 'AVAILABLE',
        };
      }).toList();

      await _dbHelper.insertMultipleTables(tableMaps);

      // ALSO store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tablesKey, jsonEncode(tableMaps));

      if (kDebugMode) {
        print('Tables cached successfully: ${tableMaps.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching tables: $e');
      }
    }
  }

  // ===========================================
  // GET CACHED DATA - Try SharedPreferences first, then Database
  // ===========================================

  Future<List<Map<String, dynamic>>> getCachedCategories() async {
    try {
      // Try SharedPreferences first (faster)
      final prefs = await SharedPreferences.getInstance();
      final categoriesString = prefs.getString(_categoriesKey);

      if (categoriesString != null) {
        final categoriesJson = jsonDecode(categoriesString) as List;
        return categoriesJson.cast<Map<String, dynamic>>();
      }

      // Fallback to database
      return await _dbHelper.getCategories();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached categories: $e');
      }
      // Fallback to database
      return await _dbHelper.getCategories();
    }
  }

  Future<List<Map<String, dynamic>>> getCachedProducts(
      [String? categoryId]) async {
    try {
      if (categoryId != null) {
        // Try SharedPreferences first for specific category
        final prefs = await SharedPreferences.getInstance();
        final productsString = prefs.getString('${_productsKey}_$categoryId');

        if (productsString != null) {
          final productsJson = jsonDecode(productsString) as List;
          return productsJson.cast<Map<String, dynamic>>();
        }
      }

      // Fallback to database
      return await _dbHelper.getProducts(categoryId);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached products: $e');
      }
      // Fallback to database
      return await _dbHelper.getProducts(categoryId);
    }
  }

  Future<List<Map<String, dynamic>>> getCachedTables() async {
    try {
      // Try SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      final tablesString = prefs.getString(_tablesKey);

      if (tablesString != null) {
        final tablesJson = jsonDecode(tablesString) as List;
        return tablesJson.cast<Map<String, dynamic>>();
      }

      // Fallback to database
      return await _dbHelper.getTables();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached tables: $e');
      }
      // Fallback to database
      return await _dbHelper.getTables();
    }
  }

  // ===========================================
  // ADDITIONAL CART OPERATIONS USING SHAREDPREFERENCES
  // ===========================================

  // Save cart using SharedPreferences (for quick access)
  Future<void> saveCartToPreferences(
      List<Map<String, dynamic>> cartItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartKey, jsonEncode(cartItems));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cart to preferences: $e');
      }
    }
  }

  // Get cart from SharedPreferences
  Future<List<Map<String, dynamic>>> getCartFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);

      if (cartString != null) {
        final cartJson = jsonDecode(cartString) as List;
        return cartJson.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cart from preferences: $e');
      }
      return [];
    }
  }

  // Clear cart from SharedPreferences
  Future<void> clearCartFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cart from preferences: $e');
      }
    }
  }

  // ===========================================
  // UTILITY METHODS
  // ===========================================

  // Clear all cached data (both SharedPreferences and Database)
  Future<void> clearAllCachedData() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_categoriesKey);
      await prefs.remove(_productsKey);
      await prefs.remove(_cartKey);
      await prefs.remove(_tablesKey);

      // Clear Database
      await _dbHelper.clearAllData();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cached data: $e');
      }
    }
  }

  // Check if data exists in cache
  Future<bool> hasCachedCategories() async {
    final categories = await getCachedCategories();
    return categories.isNotEmpty;
  }

  Future<bool> hasCachedProducts(String categoryId) async {
    final products = await getCachedProducts(categoryId);
    return products.isNotEmpty;
  }

  Future<bool> hasCachedTables() async {
    final tables = await getCachedTables();
    return tables.isNotEmpty;
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
