import 'package:hive/hive.dart';

// part 'hive_product_adapter.g.dart';

@HiveType(typeId: 2)
class HiveSupplier {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  HiveSupplier({required this.id, required this.name});
}