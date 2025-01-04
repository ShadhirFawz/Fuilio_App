import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../widgets/expense_stats.dart';
import 'expense_stats_display.dart';

class ExpenseList extends StatefulWidget {
  final String userId;
  final String vehicleId;

  const ExpenseList({required this.userId, required this.vehicleId, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseList> {
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _expensesFuture = ExpenseService(
      userId: widget.userId,
      vehicleId: widget.vehicleId,
    ).getExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Records'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(51, 48, 91, 1),
              Color.fromARGB(255, 26, 76, 214),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Expense Records',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                    return const Center(
                        child: Text('Error fetching expenses.',
                            style: TextStyle(color: Colors.white)));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No expense records.',
                            style: TextStyle(color: Colors.white)));
                  }

                  final expenses = snapshot.data!;
                  final stats = ExpenseStats(expenses);

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ExpenseStatsDisplay(stats: stats),
                        // You can add the list of individual expenses below
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              elevation: 4,
                              child: ListTile(
                                title: Text(expense.type),
                                subtitle: Text('Amount: Rs ${expense.amount}'),
                                trailing: Text(expense.date
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
