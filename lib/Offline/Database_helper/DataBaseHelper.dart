import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'restaurant_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        image TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        image TEXT,
        basePrice REAL,
        availableQuantity INTEGER,
        categoryId TEXT,
        addons TEXT,
        stockMaintenance INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Tables table
    await db.execute('''
      CREATE TABLE restaurant_tables (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        status TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    // Orders table (for offline orders)
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        orderData TEXT NOT NULL,
        orderStatus TEXT,
        sync_status INTEGER DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    // Billing items table (for cart persistence)
    await db.execute('''
      CREATE TABLE billing_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT,
        product_data TEXT NOT NULL,
        quantity INTEGER,
        created_at INTEGER
      )
    ''');
  }

  // Categories CRUD
  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    category['created_at'] = DateTime.now().millisecondsSinceEpoch;
    category['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.insert('categories', category,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'name ASC');
  }

  Future<int> insertMultipleCategories(
      List<Map<String, dynamic>> categories) async {
    final db = await database;
    final batch = db.batch();

    for (var category in categories) {
      category['created_at'] = DateTime.now().millisecondsSinceEpoch;
      category['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      batch.insert('categories', category,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final results = await batch.commit();
    return results.length;
  }

  // Products CRUD
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    // Convert addons list to JSON string
    if (product['addons'] != null) {
      product['addons'] = jsonEncode(product['addons']);
    }
    product['created_at'] = DateTime.now().millisecondsSinceEpoch;
    product['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.insert('products', product,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getProducts([String? categoryId]) async {
    final db = await database;
    List<Map<String, dynamic>> products;

    if (categoryId != null && categoryId.isNotEmpty) {
      products = await db.query('products',
          where: 'categoryId = ?',
          whereArgs: [categoryId],
          orderBy: 'name ASC');
    } else {
      products = await db.query('products', orderBy: 'name ASC');
    }

    // Convert addons JSON string back to List
    return products.map((product) {
      if (product['addons'] != null && product['addons'] != '') {
        try {
          product['addons'] = jsonDecode(product['addons']);
        } catch (e) {
          product['addons'] = [];
        }
      } else {
        product['addons'] = [];
      }
      return product;
    }).toList();
  }

  Future<int> insertMultipleProducts(
      List<Map<String, dynamic>> products) async {
    final db = await database;
    final batch = db.batch();

    for (var product in products) {
      if (product['addons'] != null) {
        product['addons'] = jsonEncode(product['addons']);
      }
      product['created_at'] = DateTime.now().millisecondsSinceEpoch;
      product['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      batch.insert('products', product,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final results = await batch.commit();
    return results.length;
  }

  // Tables CRUD
  Future<int> insertTable(Map<String, dynamic> table) async {
    final db = await database;
    table['created_at'] = DateTime.now().millisecondsSinceEpoch;
    table['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.insert('restaurant_tables', table,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getTables() async {
    final db = await database;
    return await db.query('restaurant_tables', orderBy: 'name ASC');
  }

  Future<int> insertMultipleTables(List<Map<String, dynamic>> tables) async {
    final db = await database;
    final batch = db.batch();

    for (var table in tables) {
      table['created_at'] = DateTime.now().millisecondsSinceEpoch;
      table['updated_at'] = DateTime.now().millisecondsSinceEpoch;
      batch.insert('restaurant_tables', table,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final results = await batch.commit();
    return results.length;
  }

  // Billing Items (Cart persistence)
  Future<int> saveBillingItems(List<Map<String, dynamic>> billingItems) async {
    final db = await database;

    // Clear existing billing items
    await db.delete('billing_items');

    // Insert new billing items
    final batch = db.batch();
    for (var item in billingItems) {
      batch.insert('billing_items', {
        'product_id': item['_id'],
        'product_data': jsonEncode(item),
        'quantity': item['qty'],
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }

    final results = await batch.commit();
    return results.length;
  }

  Future<List<Map<String, dynamic>>> getBillingItems() async {
    final db = await database;
    final items = await db.query('billing_items');

    return items.map((item) {
      return jsonDecode(item['product_data'] as String) as Map<String, dynamic>;
    }).toList();
  }

  Future<int> clearBillingItems() async {
    final db = await database;
    return await db.delete('billing_items');
  }

  // Orders (for offline orders)
  Future<int> saveOfflineOrder(Map<String, dynamic> orderData) async {
    final db = await database;
    return await db.insert('orders', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'orderData': jsonEncode(orderData),
      'orderStatus': 'PENDING_SYNC',
      'sync_status': 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncOrders() async {
    final db = await database;
    return await db.query('orders', where: 'sync_status = ?', whereArgs: [0]);
  }

  Future<int> markOrderAsSynced(String orderId) async {
    final db = await database;
    return await db.update('orders',
        {'sync_status': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?', whereArgs: [orderId]);
  }

  // Utility methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('categories');
    await db.delete('products');
    await db.delete('restaurant_tables');
    await db.delete('billing_items');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
