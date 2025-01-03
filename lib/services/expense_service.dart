import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  final String vehicleId;

  ExpenseService({required this.userId, required this.vehicleId});

  // Add a new expense
  Future<void> addExpense(Expense expense) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('expenses')
          .doc(expense.expenseId)
          .set(expense.toMap());
      logger.i("Expense added successfully: ${expense.expenseId}");
    } catch (e) {
      logger.e("Error adding expense: $e");
      rethrow;
    }
  }

  // Retrieve all expenses for the given vehicle
  Future<List<Expense>> getExpenses() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
    } catch (e) {
      logger.e("Error retrieving expenses: $e");
      return [];
    }
  }
}
