import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/expense_stats.dart';
import '../services/expense_service.dart'; // Import the service file

class ExpenseStatsDisplay extends StatefulWidget {
  final ExpenseStats stats;
  final String userId; // Add userId
  final String vehicleId; // Add vehicleId

  const ExpenseStatsDisplay({
    super.key,
    required this.stats,
    required this.userId, // Pass userId in the constructor
    required this.vehicleId, // Pass vehicleId in the constructor
  });

  @override
  // ignore: library_private_types_in_public_api
  _ExpenseStatsDisplayState createState() => _ExpenseStatsDisplayState();
}

class _ExpenseStatsDisplayState extends State<ExpenseStatsDisplay> {
  late ExpenseStats stats;

  @override
  void initState() {
    super.initState();
    stats = widget.stats;
  }

  // Function to show the confirmation dialog before resetting expenses
  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text('Are you sure you want to delete all expenses?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontFamily: 'Times New Roman',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _resetExpenses(); // Call the reset function
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontFamily: 'Times New Roman',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetExpenses() async {
    try {
      // Pass userId and vehicleId to the ExpenseService constructor
      await ExpenseService(userId: widget.userId, vehicleId: widget.vehicleId)
          .deleteAllExpenses();
      setState(() {
        stats = ExpenseStats([]); // Reset the stats to empty list
      });
      // Display a confirmation SnackBar
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All expenses have been deleted'),
        ),
      );
    } catch (e) {
      // Handle error gracefully (e.g., show a Snackbar or dialog)
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting expenses: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalExpense = stats.totalTireReplacement +
        stats.totalOilChange +
        stats.totalBrakePads +
        stats.totalOther;

    final List<PieChartSectionData> sections = [
      _buildPieChartSection(
          'Tire Replacement', stats.totalTireReplacement, Colors.blue),
      _buildPieChartSection('Oil Change', stats.totalOilChange, Colors.orange),
      _buildPieChartSection('Brake Pads', stats.totalBrakePads, Colors.purple),
      _buildPieChartSection('Other Expenses', stats.totalOther, Colors.green),
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pie Chart and Legend
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Pie Chart
                SizedBox(
                  height: 180,
                  width: 180,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 70,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),

                // Space between Pie Chart and Legend
                const SizedBox(width: 25),

                // Legend
                _buildLegend(),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Single Horizontal Bar Showing All Expenses Proportionally
          _buildTotalBar(totalExpense),

          // Display Total Expense in a Filled Rectangle with Reset Button
          const SizedBox(height: 20),
          _buildTotalExpenseRectangle(totalExpense),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieChartSection(
      String label, double value, Color color) {
    return PieChartSectionData(
      color: color,
      value: value,
      radius: 30,
      showTitle: false,
    );
  }

  Widget _buildLegend() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendItem(color: Colors.blue, label: 'Tire Replacement'),
        _LegendItem(color: Colors.orange, label: 'Oil Change'),
        _LegendItem(color: Colors.purple, label: 'Brake Pads'),
        _LegendItem(color: Colors.green, label: 'Other Expenses'),
      ],
    );
  }

  /// Single Horizontal Bar with Padding and Overlapping Sections
  Widget _buildTotalBar(double totalExpense) {
    final double tirePercentage = stats.totalTireReplacement / totalExpense;
    final double oilPercentage = stats.totalOilChange / totalExpense;
    final double brakePercentage = stats.totalBrakePads / totalExpense;
    final double otherPercentage = stats.totalOther / totalExpense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(15),
          child: Text(
            'Total Expense Breakdown',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Source Sans',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 7),

        // Horizontal Bar with Expense Proportions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Horizontal Bar
              Container(
                height: 15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildBarSection(Colors.blue, tirePercentage),
                    _buildBarSection(Colors.orange, oilPercentage),
                    _buildBarSection(Colors.purple, brakePercentage),
                    _buildBarSection(Colors.green, otherPercentage),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Expense Values Displayed Below the Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildExpenseLabel(
                      ' ${stats.totalTireReplacement.toStringAsFixed(2)}',
                      Colors.blue),
                  _buildExpenseLabel(
                      ' ${stats.totalOilChange.toStringAsFixed(2)}',
                      Colors.orange),
                  _buildExpenseLabel(
                      ' ${stats.totalBrakePads.toStringAsFixed(2)}',
                      Colors.purple),
                  _buildExpenseLabel(
                      ' ${stats.totalOther.toStringAsFixed(2)}', Colors.green),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// Helper method to create each colored section within the bar
  Widget _buildBarSection(Color color, double percentage) {
    return Expanded(
      flex: (percentage * 100).round(),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Helper widget to display each expense label with color
  Widget _buildExpenseLabel(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Display Total Expense inside a Filled Rectangle with Circular Corners
  Widget _buildTotalExpenseRectangle(double totalExpense) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // The label text placed outside the rectangle
          const Text(
            'Cost ',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Noticia',
              color:
                  Color.fromARGB(255, 208, 157, 157), // Adjust color as needed
            ),
          ),

          // Rectangle containing the expense value
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
            decoration: BoxDecoration(
              color: const Color.fromARGB(173, 99, 48, 6), // Background color
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Rs ${totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Noticia',
                color: Colors.white,
              ),
            ),
          ),

          // Delete Forever Button with Rectangle Background Added
          Container(
            decoration: BoxDecoration(
              color: Colors.red, // Red background for delete button
              borderRadius:
                  BorderRadius.circular(12), // Slightly rounded corners
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              onPressed: _showResetConfirmationDialog, // Show the dialog
              tooltip: 'Delete Forever',
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
