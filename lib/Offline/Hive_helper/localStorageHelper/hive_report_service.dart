import 'package:hive/hive.dart';
import 'package:simple/Offline/Hive_helper/LocalClass/Report/hive_report_model.dart';

class HiveReportService {
  static const String REPORTS_BOX = 'reportsBox';

  // Save all reports
  static Future<void> saveReports(List<HiveReportModel> reports) async {
    var box = await Hive.openBox<HiveReportModel>(REPORTS_BOX);
    await box.clear(); // clear old data
    for (var report in reports) {
      await box.put('${report.date}-${report.tableNo}-${report.productName}', report);
    }
  }

  // Fetch reports filtered by date, table, or waiter
  static Future<List<HiveReportModel>> getReports({
    DateTime? fromDate,
    DateTime? toDate,
    String? tableNo,
    String? waiterId,
  }) async {
    var box = await Hive.openBox<HiveReportModel>(REPORTS_BOX);
    var reports = box.values.toList();

    if (fromDate != null && toDate != null) {
      reports = reports.where((r) =>
      r.date.isAfter(fromDate.subtract(Duration(seconds:1))) &&
          r.date.isBefore(toDate.add(Duration(days:1)))
      ).toList();
    }

    if (tableNo != null) {
      reports = reports.where((r) => r.tableNo == tableNo).toList();
    }

    if (waiterId != null) {
      reports = reports.where((r) => r.waiterId == waiterId).toList();
    }

    return reports;
  }
}
