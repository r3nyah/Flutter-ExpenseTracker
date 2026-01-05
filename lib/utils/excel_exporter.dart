import '../models/transaction_model.dart';

// Conditional import
import 'excel_exporter_mobile.dart'
if (dart.library.html) 'excel_exporter_web.dart';

abstract class ExcelExporter {
  static Future<void> export(
      List<ExpenseTransaction> transactions,
      String fileName,
      ) {
    return ExcelExporterImpl.export(transactions, fileName);
  }
}
