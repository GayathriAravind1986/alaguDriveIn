import 'package:hive/hive.dart';

part 'hive_location_model.g.dart';

@HiveType(typeId: 12)
class HiveLocation extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? locationName;

  @HiveField(2) // FIXED: Add locationId field
  String? locationId;

  HiveLocation({
    this.id,
    this.locationName,
    this.locationId,
  });
}
