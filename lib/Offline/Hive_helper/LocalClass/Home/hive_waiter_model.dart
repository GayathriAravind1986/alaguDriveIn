import 'package:hive/hive.dart';
import 'package:simple/ModelClass/Waiter/getWaiterModel.dart' as waiter;

part 'hive_waiter_model.g.dart';

@HiveType(typeId: 15)
class HiveWaiter extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  bool? isAvailable;

  @HiveField(3)
  String? locationId;

  @HiveField(4)
  String? locationName;

  @HiveField(5)
  String? createdBy;

  @HiveField(6)
  String? createdAt;

  @HiveField(7)
  String? updatedAt;

  @HiveField(8)
  String? statusText;

  @HiveField(9)
  String? status; // For internal status tracking (AVAILABLE, BUSY, etc.)

  @HiveField(10)
  DateTime? lastUpdated;

  HiveWaiter({
    this.id,
    this.name,
    this.isAvailable,
    this.locationId,
    this.locationName,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.statusText,
    this.status,
    this.lastUpdated,
  });

  // Convert from API Data model to HiveWaiter
  factory HiveWaiter.fromApiModel(waiter.Data apiData) {
    return HiveWaiter(
      id: apiData.id,
      name: apiData.name,
      isAvailable: apiData.isAvailable,
      locationId: apiData.locationId?.id,
      locationName: apiData.locationName,
      createdBy: apiData.createdBy,
      createdAt: apiData.createdAt,
      updatedAt: apiData.updatedAt,
      statusText: apiData.statusText,
      status: apiData.isAvailable == true ? 'AVAILABLE' : 'BUSY',
      lastUpdated: DateTime.now(),
    );
  }

  // Convert from HiveWaiter to API Data model
  waiter.Data toApiModel() {
    return waiter.Data(
      id: id,
      name: name,
      isAvailable: isAvailable,
      locationId: locationId != null
          ? waiter.LocationId(id: locationId, name: locationName)
          : null,
      locationName: locationName,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      statusText: statusText,
    );
  }

  // Convert from Map (for backward compatibility if needed)
  factory HiveWaiter.fromMap(Map<String, dynamic> map) {
    return HiveWaiter(
      id: map['id'],
      name: map['name'],
      isAvailable: map['isAvailable'],
      locationId: map['locationId'],
      locationName: map['locationName'],
      createdBy: map['createdBy'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      statusText: map['statusText'],
      status: map['status'],
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
    );
  }

  // Convert to Map (for backward compatibility if needed)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isAvailable': isAvailable,
      'locationId': locationId,
      'locationName': locationName,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'statusText': statusText,
      'status': status,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Update waiter status
  void updateStatus(String newStatus, bool available) {
    status = newStatus;
    isAvailable = available;
    statusText = available ? 'Available' : 'Busy';
    lastUpdated = DateTime.now();
    updatedAt = DateTime.now().toIso8601String();
    save(); // Save to Hive
  }

  // Helper methods
  bool get isBusy => status == 'BUSY' || isAvailable == false;
  bool get isWaiterAvailable => status == 'AVAILABLE' || isAvailable == true;

  String get displayStatus =>
      statusText ?? (isAvailable == true ? 'Available' : 'Busy');

  // Check if data is stale (more than 24 hours old)
  bool get isDataStale {
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated!) > Duration(hours: 24);
  }
}