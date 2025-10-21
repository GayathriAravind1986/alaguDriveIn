// lib/helpers/app_config.dart
import 'package:hive/hive.dart';

class AppConfig {
  static const _boxName = 'appConfigBox';

  static Future<void> saveConfig(Map<String, dynamic> data) async {
    final box = Hive.box(_boxName);
    await box.put('businessName', data['businessName'] ?? box.get('businessName') ?? '');
    await box.put('address', data['address'] ?? box.get('address') ?? '');
    await box.put('gstNumber', data['gstNumber'] ?? box.get('gstNumber') ?? '');
    await box.put('phone', data['phone'] ?? box.get('phone') ?? '');
    await box.put('currencySymbol', data['currencySymbol'] ?? box.get('currencySymbol') ?? '₹');
    await box.put('printType', data['printType'] ?? box.get('printType') ?? 'imin');
    await box.put('thermalIp', data['thermalIp'] ?? box.get('thermalIp') ?? '');
    await box.put('taxName', data['taxName'] ?? box.get('taxName') ?? 'GST');
  }

  static Map<String, dynamic> readConfig() {
    final box = Hive.box(_boxName);
    return {
      'businessName': box.get('businessName', defaultValue: 'Unknown Business'),
      'address': box.get('address', defaultValue: 'Unknown Address'),
      'gstNumber': box.get('gstNumber', defaultValue: ''),
      'phone': box.get('phone', defaultValue: ''),
      'currencySymbol': box.get('currencySymbol', defaultValue: '₹'),
      'printType': box.get('printType', defaultValue: 'imin'),
      'thermalIp': box.get('thermalIp', defaultValue: ''),
      'taxName': box.get('taxName', defaultValue: 'GST'),
    };
  }

  static T readKey<T>(String key, {required T defaultValue}) {
    final box = Hive.box(_boxName);
    return box.get(key, defaultValue: defaultValue) as T;
  }
}
