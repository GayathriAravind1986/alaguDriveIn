import 'package:hive/hive.dart';

part 'hive_selected_addons_model.g.dart';

@HiveType(typeId: 3)
class HiveSelectedAddon extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  double? price;

  @HiveField(3)
  int? quantity;

  @HiveField(4)
  bool? isAvailable;

  @HiveField(5)
  int? maxQuantity;

  @HiveField(6)
  bool? isFree;

  HiveSelectedAddon({
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.isAvailable,
    this.maxQuantity,
    this.isFree,
  });

  Map<String, dynamic> toMap() {
    return {
      "_id": id,
      "name": name,
      "price": price,
      "quantity": quantity,
      "isAvailable": isAvailable,
      "maxQuantity": maxQuantity,
      "isFree": isFree,
    };
  }

  static HiveSelectedAddon fromMap(Map<String, dynamic> map) {
    return HiveSelectedAddon(
      id: map["_id"],
      name: map["name"],
      price: map["price"]?.toDouble(),
      quantity: map["quantity"],
      isAvailable: map["isAvailable"],
      maxQuantity: map["maxQuantity"],
      isFree: map["isFree"],
    );
  }
}
