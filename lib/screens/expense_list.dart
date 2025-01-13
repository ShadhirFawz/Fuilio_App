import 'package:flutter/material.dart';
import 'package:fuilio_app/screens/add_expense_screen.dart';
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
    setState(() {
      _expensesFuture = _expenseService.getExpenses();
    });
  }

  /// Function to show the notes popup dialog when a card is pressed
  /// Function to show the notes popup dialog when a card is pressed
  void _showNotesPopup(String? notes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Notes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          content: Text(
            notes?.isNotEmpty == true ? notes! : 'No notes available.',
            style: const TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(51, 48, 91, 1),
              Color.fromARGB(181, 77, 13, 149),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Expense Records',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Times New Roman',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                // FutureBuilder to load expenses and display stats + records
                FutureBuilder<List<Expense>>(
                  future: _expensesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error fetching expenses.',
                            style: TextStyle(color: Colors.white)),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        width: double.infinity,
                        height: MediaQuery.of(context)
                            .size
                            .height, // Fill the screen height
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(51, 48, 91, 1),
                              Color.fromARGB(181, 77, 13, 149),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'No expense records.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                        ),
                      );
                    }

                    final expenses = snapshot.data!;
                    final stats = ExpenseStats(expenses);

                    return Column(
                      children: [
                        ExpenseStatsDisplay(
                          stats: stats,
                          userId: widget.userId,
                          vehicleId: widget.vehicleId,
                        ),
                        const SizedBox(height: 15),

                        // Expense Cards with Note Popup on Press
                        ...expenses.map((expense) => GestureDetector(
                              onTap: () => _showNotesPopup(expense.notes),
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                elevation: 4,
                                child: ListTile(
                                  title: Text(
                                    expense.type,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Rufina',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Amount: Rs ${expense.amount}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Noticia',
                                    ),
                                  ),
                                  trailing: Text(
                                    expense.date
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color:
                                            Color.fromARGB(255, 140, 122, 122)),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }
}
