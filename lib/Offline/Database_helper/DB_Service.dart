// db_factory.dart
import 'dart:io';
import 'package:sqflite/sqflite.dart'
    if (dart.library.ffi) 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseFactoryHelper {
  static void init() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
}
