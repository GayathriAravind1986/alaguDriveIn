import 'package:hive/hive.dart';

part 'hive_cart_model.g.dart';

@HiveType(typeId: 2)
class HiveCartItem extends HiveObject {
  @HiveField(0)
  String? product;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? image;

  @HiveField(3)
  int? quantity;

  @HiveField(4)
  double? unitPrice;

  @HiveField(5)
  double? basePrice;

  @HiveField(6)
  double? subtotal;

  @HiveField(7)
  List<Map<String, dynamic>>? selectedAddons;

  @HiveField(8)
  bool? isFree;

  @HiveField(9)
  double? taxPrice;

  @HiveField(10)
  double? totalPrice;

  @HiveField(11)
  String? id; // Added for billing compatibility

  @HiveField(12)
  int? qty; // Added for billing compatibility

  @HiveField(13)
  int? availableQuantity; // Added for billing compatibility

  HiveCartItem({
    this.product,
    this.name,
    this.image,
    this.quantity,
    this.unitPrice,
    this.basePrice,
    this.subtotal,
    this.selectedAddons,
    this.isFree,
    this.taxPrice,
    this.totalPrice,
    this.id,
    this.qty,
    this.availableQuantity,
  });

  /// Main factory method that handles both online and offline data structures
  factory HiveCartItem.fromMap(Map<String, dynamic> map) {
    // Check if this is offline data structure (has 'product' field)
    // or online data structure (might have different field names)

    final quantity = _safeInt(map["quantity"] ?? map["qty"]);

    return HiveCartItem(
      // Handle product ID (can be 'product', 'productId', or '_id')
      product: map["product"]?.toString() ??
          map["productId"]?.toString() ??
          map["_id"]?.toString(),

      // Handle ID field
      id: map["id"]?.toString() ??
          map["product"]?.toString() ??
          map["productId"]?.toString() ??
          map["_id"]?.toString(),

      // Handle name
      name: map["name"]?.toString() ?? "",

      // Handle image
      image: map["image"]?.toString() ?? "",

      // Handle quantity (can be 'quantity' or 'qty')
      quantity: quantity,
      qty: quantity, // Same as quantity for compatibility

      // Handle available quantity
      availableQuantity: _safeInt(map["availableQuantity"] ?? quantity),

      // Handle unit price (can be 'unitPrice', 'basePrice', or 'price')
      unitPrice: _safeDouble(map["unitPrice"] ?? map["basePrice"] ?? map["price"]),

      // Handle base price
      basePrice: _safeDouble(map["basePrice"] ?? map["unitPrice"]),

      // Handle subtotal
      subtotal: _safeDouble(map["subtotal"]),

      // Handle selected addons (provide empty list if null)
      selectedAddons: _safeAddonsList(map["selectedAddons"] ?? map["addons"]),

      // Handle boolean fields
      isFree: map["isFree"] ?? false,

      // Handle tax and total prices
      taxPrice: _safeDouble(map["taxPrice"]),
      totalPrice: _safeDouble(map["totalPrice"]),
    );
  }

  /// Helper method to safely convert to int
  static int _safeInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  /// Helper method to safely convert to double
  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper method to safely convert addons list
  static List<Map<String, dynamic>> _safeAddonsList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) {
        if (item is Map<String, dynamic>) return item;
        if (item is Map) return Map<String, dynamic>.from(item);
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  /// Convert HiveCartItem back to Map
  Map<String, dynamic> toMap() {
    return {
      "product": product,
      "id": id,
      "name": name,
      "image": image,
      "quantity": quantity,
      "qty": qty,
      "availableQuantity": availableQuantity,
      "unitPrice": unitPrice,
      "basePrice": basePrice,
      "subtotal": subtotal,
      "selectedAddons": selectedAddons,
      "isFree": isFree,
      "taxPrice": taxPrice,
      "totalPrice": totalPrice,
    };
  }

  @override
  String toString() {
    return 'HiveCartItem(id: $id, product: $product, name: $name, quantity: $quantity, unitPrice: $unitPrice, subtotal: $subtotal)';
  }
}