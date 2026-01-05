import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    if (bytes == null) {
      throw Exception('Excel encode failed');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName.xlsx');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)]);
  }
}
