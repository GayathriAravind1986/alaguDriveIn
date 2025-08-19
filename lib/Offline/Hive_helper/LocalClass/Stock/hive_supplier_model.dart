import 'package:hive/hive.dart';

part 'hive_supplier_model.g.dart';

@HiveType(typeId: 14)
class HiveSupplier extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  HiveSupplier({this.id, this.name});
}
