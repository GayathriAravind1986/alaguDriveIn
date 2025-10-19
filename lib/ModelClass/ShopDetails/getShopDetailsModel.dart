import 'dart:convert';
import 'package:simple/Bloc/Response/errorResponse.dart';
/// success : true
/// data : {"sortOrder":0,"connectionType":"WIFI","_id":"68903a7bf7a56be2b7654f2f","name":"ALANGULAM","description":"alangulam","isDefault":true,"createdBy":"6890315266eb7a8181a3b4b4","createdAt":"2025-08-04T04:43:39.685Z","updatedAt":"2025-09-29T10:00:35.930Z","__v":0,"setDefault":true,"ipAddress":"192.168.1.5","address":"","city":"s","contactNumber":"s","gstNumber":"s","state":"s","thermalIp":"192.168.1.5","zipCode":"s"}

GetShopDetailsModel getShopDetailsModelFromJson(String str) => GetShopDetailsModel.fromJson(json.decode(str));
String getShopDetailsModelToJson(GetShopDetailsModel data) => json.encode(data.toJson());
class GetShopDetailsModel
{
  GetShopDetailsModel({
      bool? success, 
      Data? data,
    ErrorResponse? errorResponse,
  }){
    _success = success;
    _data = data;
    this.errorResponse = errorResponse;
}

  GetShopDetailsModel.fromJson(dynamic json) {

    _success = json['success'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }
  bool? _success;
  Data? _data;
  ErrorResponse? errorResponse;
GetShopDetailsModel copyWith({  bool? success,
  Data? data,
}) => GetShopDetailsModel(  success: success ?? _success,
  data: data ?? _data,
);
  bool? get success => _success;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

/// sortOrder : 0
/// connectionType : "WIFI"
/// _id : "68903a7bf7a56be2b7654f2f"
/// name : "ALANGULAM"
/// description : "alangulam"
/// isDefault : true
/// createdBy : "6890315266eb7a8181a3b4b4"
/// createdAt : "2025-08-04T04:43:39.685Z"
/// updatedAt : "2025-09-29T10:00:35.930Z"
/// __v : 0
/// setDefault : true
/// ipAddress : "192.168.1.5"
/// address : ""
/// city : "s"
/// contactNumber : "s"
/// gstNumber : "s"
/// state : "s"
/// thermalIp : "192.168.1.5"
/// zipCode : "s"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      num? sortOrder, 
      String? connectionType, 
      String? id, 
      String? name, 
      String? description, 
      bool? isDefault, 
      String? createdBy, 
      String? createdAt, 
      String? updatedAt, 
      num? v, 
      bool? setDefault, 
      String? ipAddress, 
      String? address, 
      String? city, 
      String? contactNumber, 
      String? gstNumber, 
      String? state, 
      String? thermalIp, 
      String? zipCode,}){
    _sortOrder = sortOrder;
    _connectionType = connectionType;
    _id = id;
    _name = name;
    _description = description;
    _isDefault = isDefault;
    _createdBy = createdBy;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
    _setDefault = setDefault;
    _ipAddress = ipAddress;
    _address = address;
    _city = city;
    _contactNumber = contactNumber;
    _gstNumber = gstNumber;
    _state = state;
    _thermalIp = thermalIp;
    _zipCode = zipCode;
}

  Data.fromJson(dynamic json) {
    _sortOrder = json['sortOrder'];
    _connectionType = json['connectionType'];
    _id = json['_id'];
    _name = json['name'];
    _description = json['description'];
    _isDefault = json['isDefault'];
    _createdBy = json['createdBy'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
    _setDefault = json['setDefault'];
    _ipAddress = json['ipAddress'];
    _address = json['address'];
    _city = json['city'];
    _contactNumber = json['contactNumber'];
    _gstNumber = json['gstNumber'];
    _state = json['state'];
    _thermalIp = json['thermalIp'];
    _zipCode = json['zipCode'];
  }
  num? _sortOrder;
  String? _connectionType;
  String? _id;
  String? _name;
  String? _description;
  bool? _isDefault;
  String? _createdBy;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  bool? _setDefault;
  String? _ipAddress;
  String? _address;
  String? _city;
  String? _contactNumber;
  String? _gstNumber;
  String? _state;
  String? _thermalIp;
  String? _zipCode;
Data copyWith({  num? sortOrder,
  String? connectionType,
  String? id,
  String? name,
  String? description,
  bool? isDefault,
  String? createdBy,
  String? createdAt,
  String? updatedAt,
  num? v,
  bool? setDefault,
  String? ipAddress,
  String? address,
  String? city,
  String? contactNumber,
  String? gstNumber,
  String? state,
  String? thermalIp,
  String? zipCode,
}) => Data(  sortOrder: sortOrder ?? _sortOrder,
  connectionType: connectionType ?? _connectionType,
  id: id ?? _id,
  name: name ?? _name,
  description: description ?? _description,
  isDefault: isDefault ?? _isDefault,
  createdBy: createdBy ?? _createdBy,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  v: v ?? _v,
  setDefault: setDefault ?? _setDefault,
  ipAddress: ipAddress ?? _ipAddress,
  address: address ?? _address,
  city: city ?? _city,
  contactNumber: contactNumber ?? _contactNumber,
  gstNumber: gstNumber ?? _gstNumber,
  state: state ?? _state,
  thermalIp: thermalIp ?? _thermalIp,
  zipCode: zipCode ?? _zipCode,
);
  num? get sortOrder => _sortOrder;
  String? get connectionType => _connectionType;
  String? get id => _id;
  String? get name => _name;
  String? get description => _description;
  bool? get isDefault => _isDefault;
  String? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;
  bool? get setDefault => _setDefault;
  String? get ipAddress => _ipAddress;
  String? get address => _address;
  String? get city => _city;
  String? get contactNumber => _contactNumber;
  String? get gstNumber => _gstNumber;
  String? get state => _state;
  String? get thermalIp => _thermalIp;
  String? get zipCode => _zipCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sortOrder'] = _sortOrder;
    map['connectionType'] = _connectionType;
    map['_id'] = _id;
    map['name'] = _name;
    map['description'] = _description;
    map['isDefault'] = _isDefault;
    map['createdBy'] = _createdBy;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    map['setDefault'] = _setDefault;
    map['ipAddress'] = _ipAddress;
    map['address'] = _address;
    map['city'] = _city;
    map['contactNumber'] = _contactNumber;
    map['gstNumber'] = _gstNumber;
    map['state'] = _state;
    map['thermalIp'] = _thermalIp;
    map['zipCode'] = _zipCode;
    return map;
  }

}