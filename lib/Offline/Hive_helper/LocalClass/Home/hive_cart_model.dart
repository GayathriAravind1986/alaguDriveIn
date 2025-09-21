import 'package:hive/hive.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_selected_addons_model.dart';

part 'hive_cart_model.g.dart';

@HiveType(typeId: 2)
class HiveCartItem extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? image;

  @HiveField(3)
  double? basePrice;

  @HiveField(4)
  double? qty;

  @HiveField(5)
  int? availableQuantity;

  @HiveField(6)
  List<HiveSelectedAddon>? selectedAddons;

  @HiveField(7)
  DateTime? createdAt;

  HiveCartItem({
    this.id,
    this.name,
    this.image,
    this.basePrice,
    this.qty,
    this.availableQuantity,
    this.selectedAddons,
    this.createdAt,
  });

  /// Convert API map -> HiveCartItem safely
  static HiveCartItem fromMap(Map<String, dynamic> map) {
    return HiveCartItem(
      id: map["_id"]?.toString(),
      name: map["name"]?.toString(),
      image: map["image"]?.toString(),
      basePrice: map["basePrice"] != null
          ? (map["basePrice"] is int
          ? (map["basePrice"] as int).toDouble()
          : map["basePrice"] as double)
          : 0.0,
      qty: map["qty"] != null
          ? (map["qty"] is int
          ? (map["qty"] as int).toDouble()
          : map["qty"] as double)
          : 0.0,
      availableQuantity: map["availableQuantity"] != null
          ? int.tryParse(map["availableQuantity"].toString())
          : 0,
      selectedAddons: (map["selectedAddons"] as List<dynamic>?)
          ?.map((addon) => HiveSelectedAddon.fromMap(
          Map<String, dynamic>.from(addon)))
          .toList(),
      createdAt: DateTime.now(),
    );
  }

  /// Convert HiveCartItem -> Map (for API payloads)
  Map<String, dynamic> toMap() {
    return {
      "_id": id,
      "name": name,
      "image": image,
      "basePrice": basePrice,
      "qty": qty,
      "availableQuantity": availableQuantity,
      "selectedAddons":
      selectedAddons?.map((addon) => addon.toMap()).toList() ?? [],
      "createdAt": createdAt?.toIso8601String(),
    };
  }
  factory HiveCartItem.fromJson(Map<String, dynamic> json) {
    return HiveCartItem(
      id: json['_id'] ?? json['product'],   // handle both cases
      name: json['name'] ?? '',
      image: json['image'] ?? '',          // default empty string if null
      basePrice: json['unitPrice'] ?? json['basePrice'] ?? 0,
      qty: json['quantity'] ?? json['qty'] ?? 0,
      // : json['subtotal'] ?? 0,
    );
  }

}
