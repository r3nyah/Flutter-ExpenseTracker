import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../add/add_transaction_screen.dart';
import '../add/dialpad_overlay.dart';
import '../history/history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const DialPadOverlay(),
          );
        },
      ),
      body: StreamBuilder<List<ExpenseTransaction>>(
        stream: context.read<TransactionProvider>().transactions(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!;
          final total =
          transactions.fold<int>(0, (sum, e) => sum + e.amount);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWeb = constraints.maxWidth >= 900;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWeb ? 1100 : double.infinity,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      crossAxisCount: isWeb ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isWeb ? 1.8 : 1.6,
                      children: [
                        TotalMonthCard(
                          total: total,
                          currency: currency,
                        ),
                        MonthDiffCard(
                          transactions: transactions,
                          currency: currency,
                        ),
                        CategoryPieCard(
                          transactions: transactions,
                          height: isWeb ? 280 : null,
                        ),
                        DailyLineChartCard(
                          transactions: transactions,
                          height: isWeb ? 280 : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


//// -------------------- TOTAL MONTH --------------------

class TotalMonthCard extends StatelessWidget {
  final int total;
  final NumberFormat currency;

  const TotalMonthCard({
    super.key,
    required this.total,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total This Month',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              currency.format(total),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//// -------------------- MONTH DIFFERENCE --------------------

class MonthDiffCard extends StatelessWidget {
  final List<ExpenseTransaction> transactions;
  final NumberFormat currency;

  const MonthDiffCard({
    super.key,
    required this.transactions,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final thisMonth = transactions.where((t) =>
    t.date.month == now.month && t.date.year == now.year);

    final lastMonth = transactions.where((t) =>
    t.date.month == now.month - 1 && t.date.year == now.year);

    final thisTotal =
    thisMonth.fold<int>(0, (sum, e) => sum + e.amount.toInt());

    final lastTotal =
    lastMonth.fold<int>(0, (sum, e) => sum + e.amount.toInt());

    final diff = thisTotal - lastTotal;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Monthly Difference'),
            const SizedBox(height: 12),
            Text(
              diff >= 0
                  ? '+ ${currency.format(diff)}'
                  : '- ${currency.format(diff.abs())}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: diff >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//// -------------------- CATEGORY PIE --------------------

class CategoryPieCard extends StatelessWidget {
  final List<ExpenseTransaction> transactions;
  final double? height;

  const CategoryPieCard({
    super.key,
    required this.transactions,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryTotals = {};

    for (var t in transactions) {
      categoryTotals[t.category] =
          (categoryTotals[t.category] ?? 0) + t.amount.toDouble();
    }

    return Card(
      elevation: 4,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Expenses by Category',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: categoryTotals.entries.map((e) {
                      return PieChartSectionData(
                        value: e.value,
                        title: e.key,
                        radius: 45,
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//// -------------------- DAILY BAR CHART --------------------
class DailyLineChartCard extends StatelessWidget {
  final List<ExpenseTransaction> transactions;
  final double? height;

  const DailyLineChartCard({
    super.key,
    required this.transactions,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Map<int, double> dailyTotals = {};

    for (var t in transactions) {
      dailyTotals[t.date.day] =
          (dailyTotals[t.date.day] ?? 0) + t.amount.toDouble();
    }

    final spots = dailyTotals.entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: height ?? 260,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Spending',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        color: Colors.teal,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.withOpacity(0.35),
                              Colors.teal.withOpacity(0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
