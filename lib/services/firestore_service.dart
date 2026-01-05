import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference transactionsRef(String uid) =>
      _db.collection('users').doc(uid).collection('transactions');

  Stream<List<ExpenseTransaction>> getTransactions(String uid) {
    return transactionsRef(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ExpenseTransaction.fromFirestore(doc))
        .toList());
  }

  Future<void> addTransaction(String uid, ExpenseTransaction tx) {
    return transactionsRef(uid).add(tx.toMap());
  }

  Future<void> deleteTransaction(String uid, String id) {
    return transactionsRef(uid).doc(id).delete();
  }
}
