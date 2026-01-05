import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:excel/excel.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';


class ExcelExporterImpl {
  static Future<void> export(
      List<ExpenseTransaction> transactions,
      String fileName,
      ) async {
    final excel = Excel.createExcel();
    final DateFormat humanDate = DateFormat('dd MMM yyyy, HH:mm');

    excel.delete('Sheet1');
    final sheet = excel['Expenses'];
    excel.setDefaultSheet('Expenses');

    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Category'),
      TextCellValue('Amount'),
      TextCellValue('Date'),
    ]);

    for (final tx in transactions) {
      sheet.appendRow([
        TextCellValue(tx.name),
        TextCellValue(tx.category),
        IntCellValue(tx.amount),
        TextCellValue(humanDate.format(tx.date)),

      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    final blob = html.Blob(
      [Uint8List.fromList(bytes)],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );

    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute('download', '$fileName.xlsx')
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
