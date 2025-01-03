import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense_model.dart';
import 'add_expense_screen.dart';

class ExpenseList extends StatefulWidget {
  final String vehicleId;
  final String userId;

  const ExpenseList({
    required this.vehicleId,
    required this.userId,
    super.key,
  });

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  late ExpenseService _expenseService;
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _expenseService = ExpenseService(
      userId: widget.userId,
      vehicleId: widget.vehicleId,
    );
    _expensesFuture = _expenseService.getExpenses();
  }

  void _navigateToAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          userId: widget.userId,
          vehicleId: widget.vehicleId,
        ),
      ),
    );
    // Reload the expense list after returning from the AddExpenseScreen
    setState(() {
      _expensesFuture = _expenseService.getExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Expense Records',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: _expensesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No expense records.'));
                }

                final expenses = snapshot.data!;
                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      title: Text(expense.type),
                      subtitle: Text('Amount: ${expense.amount}'),
                      trailing: Text(
                        expense.date.toLocal().toString().split(' ')[0],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}
