import 'package:hive/hive.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Report/hive_report_model.dart';

class HiveReportService {
  static const String REPORTS_BOX = 'reports';

  /// ✅ Save reports into Hive
  static Future<void> saveReports(List<HiveReportModel> reports) async {
    try {
      final box = await Hive.openBox<HiveReportModel>(REPORTS_BOX);
      await box.clear(); // replace old reports
      for (var report in reports) {
        await box.add(report);
      }
      print("====================== Saved ${reports.length} reports to Hive");
    } catch (e) {
      print("Error saving reports to Hive: $e");
      // If there's an error, clear the box and try again
      await clearReports();
      final box = await Hive.openBox<HiveReportModel>(REPORTS_BOX);
      for (var report in reports) {
        await box.add(report);
      }
    }
  }

  /// ✅ Fetch reports with filters
  static Future<List<HiveReportModel>> getReports({
    DateTime? fromDate,
    DateTime? toDate,
    String? tableNo,
    String? waiterId,
  }) async {
    try {
      final box = await Hive.openBox<HiveReportModel>(REPORTS_BOX);
      final allReports = box.values.toList();

      return allReports.where((report) {
        bool matches = true;

        if (fromDate != null) {
          matches &= report.date.isAfter(fromDate.subtract(const Duration(days: 1)));
        }
        if (toDate != null) {
          matches &= report.date.isBefore(toDate.add(const Duration(days: 1)));
        }
        if (tableNo != null && tableNo.isNotEmpty) {
          matches &= report.tableNo == tableNo;
        }
        if (waiterId != null && waiterId.isNotEmpty) {
          matches &= report.waiterId == waiterId;
        }

        return matches;
      }).toList();
    } catch (e) {
      print("Error reading reports from Hive: $e");
      // If there's an error reading, clear corrupt data
      await clearReports();
      return [];
    }
  }

  /// ✅ Clear all reports
  static Future<void> clearReports() async {
    try {
      final box = await Hive.openBox<HiveReportModel>(REPORTS_BOX);
      await box.clear();
      print("====================== Cleared all reports from Hive");
    } catch (e) {
      print("Error clearing reports from Hive: $e");
    }
  }
}