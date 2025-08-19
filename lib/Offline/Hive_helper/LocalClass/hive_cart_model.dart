import 'package:hive/hive.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/hive_selected_addons_model.dart';

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
  int? qty;

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
    };
  }

  static HiveCartItem fromMap(Map<String, dynamic> map) {
    return HiveCartItem(
      id: map["_id"],
      name: map["name"],
      image: map["image"],
      basePrice: map["basePrice"]?.toDouble(),
      qty: map["qty"],
      availableQuantity: map["availableQuantity"],
      selectedAddons: (map["selectedAddons"] as List<dynamic>?)
          ?.map((addon) => HiveSelectedAddon.fromMap(addon))
          .toList(),
      createdAt: DateTime.now(),
    );
  }
}
