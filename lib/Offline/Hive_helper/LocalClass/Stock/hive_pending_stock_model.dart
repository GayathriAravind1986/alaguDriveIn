import 'package:hive/hive.dart';

part 'hive_pending_stock_model.g.dart';

@HiveType(typeId: 70)
class HivePendingStock extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? payload;

  @HiveField(2)
  bool? synced;        // keep old field if it ever existed

  @HiveField(3)
  DateTime? createdAt; // new field
}
