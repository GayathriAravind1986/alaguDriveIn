import 'package:hive/hive.dart';

// part 'hive_product_stock.g.dart';

@HiveType(typeId: 3)
class HiveProductStock extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  HiveProductStock({this.id, this.name});
}
