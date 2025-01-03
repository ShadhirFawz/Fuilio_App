class Expense {
  final String expenseId;
  final String type; // Type of expense (e.g., oil change, tire replacement)
  final double amount; // Amount spent on the expense
  final DateTime date; // Date of the expense
  final String? notes;

  Expense({
    required this.expenseId,
    required this.type,
    required this.amount,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseId: map['expenseId'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }
}
