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
      final results = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      return results.docs.map((doc) => Expense.fromMap(doc.data())).toList();
    } catch (e) {
      logger.e("Error retrieving expenses: $e");
      return [];
    }
  }

  // Delete all expenses for the given vehicle
  Future<void> deleteAllExpenses() async {
    try {
      final expensesQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('expenses')
          .get();

      // Check if there are any expenses
      if (expensesQuery.docs.isEmpty) {
        logger.i("No expenses to delete.");
        return;
      }

      // Start a batch operation to delete all expenses
      WriteBatch batch = _firestore.batch();

      for (var doc in expensesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch operation
      await batch.commit();
      logger.i("All expenses deleted successfully.");
    } catch (e) {
      logger.e("Error deleting expenses: $e");
      rethrow;
    }
  }
}
