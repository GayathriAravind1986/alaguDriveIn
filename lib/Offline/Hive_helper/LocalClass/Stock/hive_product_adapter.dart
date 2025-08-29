import 'package:hive/hive.dart';

// part 'hive_product_adapter.g.dart';

@HiveType(typeId: 3)
class HiveProduct {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  HiveProduct({required this.id, required this.name});
}