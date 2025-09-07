import 'package:hive/hive.dart';
import 'package:simple/ModelClass/User/getUserModel.dart' as user;

part 'hive_user_model.g.dart';

@HiveType(typeId: 18) // Use a unique typeId
class HiveUser extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? role;

  @HiveField(4)
  String? locationId;

  @HiveField(5)
  String? locationName;

  @HiveField(6)
  String? createdAt;

  @HiveField(7)

  String? updatedAt;

  @HiveField(8)
  DateTime? lastUpdated;

  HiveUser({
    this.id,
    this.name,
    this.email,
    this.role,
    this.locationId,
    this.locationName,
    this.createdAt,
    this.updatedAt,
    this.lastUpdated,
  });

  // Convert from API Data model to HiveUser
  factory HiveUser.fromApiModel(user.Data apiData) {
    return HiveUser(
      id: apiData.id,
      name: apiData.name,
      email: apiData.email,
      role: apiData.role,
      createdAt: apiData.createdAt,
      lastUpdated: DateTime.now(),
    );
  }

  // Convert from HiveUser to API Data model
  user.Data toApiModel() {
    return user.Data(
      id: id,
      name: name,
      email: email,
      role: role,
      createdAt: createdAt,
    );
  }
}