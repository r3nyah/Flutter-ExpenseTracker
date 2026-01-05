import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';

class TransactionProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  Stream<List<ExpenseTransaction>> transactions(String uid) {
    return _service.getTransactions(uid);
  }

  Future<void> add(String uid, ExpenseTransaction tx) {
    return _service.addTransaction(uid, tx);
  }

  Future<void> delete(String uid, String id) {
    return _service.deleteTransaction(uid, id);
  }
}
