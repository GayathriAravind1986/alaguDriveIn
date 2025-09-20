import 'package:hive/hive.dart';
import 'package:simple/Bloc/Response/errorResponse.dart';

part 'hive_product_list_model.g.dart'; // run `flutter pub run build_runner build`

@HiveType(typeId: 90)
class GetProductByCatIdModel {
  @HiveField(0)
  bool? success;

  @HiveField(1)
  List<Product>? rows;

  @HiveField(2)
  num? count;

  @HiveField(3)
  bool? stockMaintenance;

  @HiveField(4)
  ErrorResponse? errorResponse;

  GetProductByCatIdModel({
    this.success,
    this.rows,
    this.count,
    this.stockMaintenance,
    this.errorResponse,
  });

  factory GetProductByCatIdModel.fromJson(Map<String, dynamic> json) {
    return GetProductByCatIdModel(
      success: json['success'],
      rows: json['rows'] != null
          ? List<Product>.from(json['rows'].map((x) => Product.fromJson(x)))
          : [],
      count: json['count'],
      stockMaintenance: json['stockMaintenance'],
      errorResponse: json['errors'] != null
          ? ErrorResponse.fromJson(json['errors'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "rows": rows?.map((e) => e.toJson()).toList(),
    "count": count,
    "stockMaintenance": stockMaintenance,
    "errors": errorResponse?.toJson(),
  };
}

@HiveType(typeId: 91)
class Product {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  Category? category;

  @HiveField(3)
  num? basePrice;

  @HiveField(4)
  bool? hasAddons;

  @HiveField(5)
  bool? isAvailable;

  @HiveField(6)
  String? createdBy;

  @HiveField(7)
  String? createdAt;

  @HiveField(8)
  String? updatedAt;

  @HiveField(9)
  num? v;

  @HiveField(10)
  String? image;

  @HiveField(11)
  List<Addon>? addons;

  @HiveField(12)
  int counter; // For UI quantity

  Product({
    this.id,
    this.name,
    this.category,
    this.basePrice,
    this.hasAddons,
    this.isAvailable,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.image,
    this.addons,
    this.counter = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"],
    name: json["name"],
    category: json["category"] != null
        ? Category.fromJson(json["category"])
        : null,
    basePrice: json["basePrice"],
    hasAddons: json["hasAddons"],
    isAvailable: json["isAvailable"],
    createdBy: json["createdBy"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    image: json["image"],
    addons: json["addons"] != null
        ? List<Addon>.from(json["addons"].map((x) => Addon.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "category": category?.toJson(),
    "basePrice": basePrice,
    "hasAddons": hasAddons,
    "isAvailable": isAvailable,
    "createdBy": createdBy,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "image": image,
    "addons": addons?.map((x) => x.toJson()).toList(),
    "counter": counter,
  };
}

@HiveType(typeId: 92)
class Addon {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  num? maxQuantity;

  @HiveField(3)
  num? price;

  @HiveField(4)
  bool? isAvailable;

  @HiveField(5)
  bool? isFree;

  @HiveField(6)
  List<String>? products;

  @HiveField(7)
  bool isSelected;

  @HiveField(8)
  num quantity;

  Addon({
    this.id,
    this.name,
    this.maxQuantity,
    this.price,
    this.isAvailable,
    this.isFree,
    this.products,
    this.isSelected = false,
    this.quantity = 0,
  });

  factory Addon.fromJson(Map<String, dynamic> json) => Addon(
    id: json["_id"],
    name: json["name"],
    maxQuantity: json["maxQuantity"],
    price: json["price"],
    isAvailable: json["isAvailable"],
    isFree: json["isFree"],
    products: json["products"] != null
        ? List<String>.from(json["products"])
        : [],
    quantity: json["quantity"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "maxQuantity": maxQuantity,
    "price": price,
    "isAvailable": isAvailable,
    "isFree": isFree,
    "products": products,
    "quantity": quantity,
    "isSelected": isSelected,
  };
}

@HiveType(typeId: 93)
class Category {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  bool? isAvailable;

  @HiveField(3)
  String? image;

  Category({this.id, this.name, this.isAvailable, this.image});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["_id"],
    name: json["name"],
    isAvailable: json["isAvailable"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "isAvailable": isAvailable,
    "image": image,
  };
}
