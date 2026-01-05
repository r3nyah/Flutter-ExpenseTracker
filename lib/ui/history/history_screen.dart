import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../utils/excel_exporter.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  List<ExpenseTransaction> _filterByMonth(
      List<ExpenseTransaction> data,
      DateTime target,
      ) {
    return data.where((t) =>
    t.date.month == target.month &&
        t.date.year == target.year
    ).toList();
  }

  List<ExpenseTransaction> _filterByYear(
      List<ExpenseTransaction> data,
      int year,
      ) {
    return data.where((t) => t.date.year == year).toList();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
      ),
      body: StreamBuilder<List<ExpenseTransaction>>(
        stream: context.read<TransactionProvider>().transactions(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!;

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return Column(
            children: [
              /// -------------------- LIST --------------------
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),

                            /// ICON
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor:
                              Colors.teal.withOpacity(0.15),
                              child: Icon(
                                _categoryIcon(tx.category),
                                color: Colors.teal,
                              ),
                            ),

                            /// TITLE
                            title: Text(
                              tx.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            /// DATE
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                DateFormat('dd MMM yyyy • HH:mm')
                                    .format(tx.date),
                                style:
                                const TextStyle(fontSize: 12),
                              ),
                            ),

                            /// AMOUNT + DELETE
                            trailing: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              crossAxisAlignment:
                              CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currency.format(tx.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () =>
                                      _confirmDelete(
                                        context,
                                        uid,
                                        tx.id,
                                      ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              /// -------------------- EXPORT BUTTONS --------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ExcelExporter.export(
                            transactions,
                            'expenses_all',
                          );
                        },
                        child: const Text('Export All'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final now = DateTime.now();
                          final filtered =
                          _filterByMonth(transactions, now);

                          ExcelExporter.export(
                            filtered,
                            'expenses_${now.month}_${now.year}',
                          );
                        },
                        child: const Text('This Month'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final year = DateTime.now().year;
                          final filtered =
                          _filterByYear(transactions, year);

                          ExcelExporter.export(
                            filtered,
                            'expenses_$year',
                          );
                        },
                        child: const Text('This Year'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Bills':
        return Icons.receipt_long;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Health':
        return Icons.favorite;
      default:
        return Icons.category;
    }
  }

  void _confirmDelete(BuildContext context, String uid, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
        const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<TransactionProvider>()
                  .delete(uid, id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
