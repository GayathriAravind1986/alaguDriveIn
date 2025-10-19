import 'package:hive/hive.dart';
import 'dart:developer' as developer;
import '../../../ModelClass/ShopDetails/getShopDetailsModel.dart';

class HiveShopDetailsService {
  static const String _boxName = 'shopDetailsBox';
  static const String _shopDetailsKey = 'shopDetails';

  static Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  // Save shop details to Hive
  static Future<void> saveShopDetails(GetShopDetailsModel shopDetails) async {
    try {
      final box = await _openBox();
      final jsonData = shopDetails.toJson();
      developer.log('💾 Saving shop details to Hive...');
      developer.log('   - Shop Name: ${shopDetails.data?.name}');
      developer.log('   - Contact: ${shopDetails.data?.contactNumber}');
      await box.put(_shopDetailsKey, jsonData);
      developer.log('✅ Shop details saved to Hive successfully');
    } catch (e) {
      developer.log('❌ Error saving shop details to Hive: $e');
      throw e;
    }
  }

  // Get shop details from Hive as GetShopDetailsModel
  static Future<GetShopDetailsModel?> getShopDetailsAsApiModel() async {
    try {
      final box = await _openBox();
      final shopDetailsJson = box.get(_shopDetailsKey);

      developer.log('📂 Reading shop details from Hive...');
      developer.log('   - Data exists: ${shopDetailsJson != null}');

      if (shopDetailsJson != null) {
        final model = GetShopDetailsModel.fromJson(shopDetailsJson);
        developer.log('✅ Successfully loaded shop details from Hive');
        developer.log('   - Shop Name: ${model.data?.name}');
        developer.log('   - Contact: ${model.data?.contactNumber}');
        return model;
      } else {
        developer.log('❌ No shop details found in Hive');
        return null;
      }
    } catch (e) {
      developer.log('❌ Error reading shop details from Hive: $e');
      return null;
    }
  }

  // Clear shop details from Hive
  static Future<void> clearShopDetails() async {
    try {
      final box = await _openBox();
      await box.delete(_shopDetailsKey);
      developer.log('🗑️ Shop details cleared from Hive');
    } catch (e) {
      developer.log('❌ Error clearing shop details from Hive: $e');
    }
  }
}