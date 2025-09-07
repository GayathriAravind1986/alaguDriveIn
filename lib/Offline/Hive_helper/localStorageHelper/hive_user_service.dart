import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:simple/ModelClass/User/getUserModel.dart' as user;
import 'package:simple/Offline/Hive_helper/LocalClass/Home/hive_user_model.dart';

class HiveUserService {
  static const String _userBox = 'users_box';
  static const String _appStateBox = 'app_state';

  // In HiveUserService
  static Future<void> saveUsers(List<user.Data> usersData) async {
    debugPrint('Saving ${usersData.length} users to Hive');
    final box = Hive.box<HiveUser>(_userBox);
    await box.clear();

    for (int i = 0; i < usersData.length; i++) {
      final hiveUser = HiveUser.fromApiModel(usersData[i]);
      await box.put('user_$i', hiveUser);
      debugPrint('Saved user: ${hiveUser.name}');
    }

    debugPrint('Total users in Hive: ${box.values.length}');
  }

  static Future<List<user.Data>> getUsersAsApiFormat() async {
    final box = Hive.box<HiveUser>(_userBox);
    final hiveUsers = box.values.toList();
    debugPrint('Retrieved ${hiveUsers.length} users from Hive');

    return hiveUsers.map((hiveUser) => hiveUser.toApiModel()).toList();
  }

  static Future<List<HiveUser>> getUsers() async {
    final box = Hive.box<HiveUser>(_userBox);
    return box.values.toList();
  }

  // static Future<List<user.Data>> getUsersAsApiFormat() async {
  //   final hiveUsers = await getUsers();
  //   return hiveUsers.map((hiveUser) => hiveUser.toApiModel()).toList();
  // }

  static Future<DateTime?> getLastUpdated() async {
    final appStateBox = Hive.box(_appStateBox);
    final dateString = appStateBox.get('users_last_updated');
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  static Future<void> clearUsers() async {
    final box = Hive.box<HiveUser>(_userBox);
    await box.clear();
  }

  static Future<int> getUserCount() async {
    final box = Hive.box<HiveUser>(_userBox);
    return box.length;
  }

  static Future<bool> hasData() async {
    final box = Hive.box<HiveUser>(_userBox);
    return box.isNotEmpty;
  }
}