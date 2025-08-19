import 'package:hive/hive.dart';
import 'package:simple/ModelClass/Table/Get_table_model.dart' as table;
part 'hive_table_model.g.dart';

@HiveType(typeId: 11)
class HiveTable extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  bool? isAvailable;

  @HiveField(3)
  String? createdBy;

  @HiveField(4)
  String? createdAt;

  @HiveField(5)
  String? updatedAt;

  @HiveField(6)
  String? statusText;

  @HiveField(7)
  String? status; // For internal status tracking (AVAILABLE, OCCUPIED, etc.)

  @HiveField(8)
  DateTime? lastUpdated;

  HiveTable({
    this.id,
    this.name,
    this.isAvailable,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.statusText,
    this.status,
    this.lastUpdated,
  });

  // Convert from API Data model to HiveTable
  factory HiveTable.fromApiModel(table.Data apiData) {
    return HiveTable(
      id: apiData.id,
      name: apiData.name,
      isAvailable: apiData.isAvailable,
      createdBy: apiData.createdBy,
      createdAt: apiData.createdAt,
      updatedAt: apiData.updatedAt,
      statusText: apiData.statusText,
      status: apiData.isAvailable == true ? 'AVAILABLE' : 'OCCUPIED',
      lastUpdated: DateTime.now(),
    );
  }

  // Convert from HiveTable to API Data model
  table.Data toApiModel() {
    return table.Data(
      id: id,
      name: name,
      isAvailable: isAvailable,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      statusText: statusText,
    );
  }

  // Keep the old toMap method for backward compatibility
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isAvailable': isAvailable,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'statusText': statusText,
      'status': status,
    };
  }

  // Create from Map
  factory HiveTable.fromMap(Map<String, dynamic> map) {
    return HiveTable(
      id: map['id'],
      name: map['name'],
      isAvailable: map['isAvailable'],
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

  // Update table status
  void updateStatus(String newStatus, bool available) {
    status = newStatus;
    isAvailable = available;
    statusText = available ? 'Available' : 'Occupied';
    lastUpdated = DateTime.now();
    updatedAt = DateTime.now().toIso8601String();
    save(); // Save to Hive
  }

  // Helper methods
  bool get isOccupied => status == 'OCCUPIED' || isAvailable == false;
  bool get isTableAvailable => status == 'AVAILABLE' || isAvailable == true;

  String get displayStatus =>
      statusText ?? (isAvailable == true ? 'Available' : 'Occupied');
}
