import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseTransaction {
  final String id;
  final String name;
  final int amount;
  final String category;
  final DateTime date;

  ExpenseTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory ExpenseTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseTransaction(
      id: doc.id,
      name: data['name'],
      amount: data['amount'],
      category: data['category'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
    };
  }
}
