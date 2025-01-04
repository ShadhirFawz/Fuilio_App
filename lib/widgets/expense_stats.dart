import '../models/expense_model.dart';

class ExpenseStats {
  final List<Expense> expenses;

  ExpenseStats(this.expenses);

  double get totalTireReplacement => _calculateTotalForType('Tire Replacement');
  double get totalOilChange => _calculateTotalForType('Oil Change');
  double get totalBrakePads => _calculateTotalForType('Brake Pads');
  double get totalOther => _calculateTotalForType('Other');
  double get totalSpent =>
      totalTireReplacement + totalOilChange + totalBrakePads + totalOther;

  double _calculateTotalForType(String type) {
    return expenses
        .where((expense) => expense.type == type)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
