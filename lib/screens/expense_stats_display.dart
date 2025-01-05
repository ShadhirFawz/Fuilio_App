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
      await ExpenseService(userId: widget.userId, vehicleId: widget.vehicleId)
          .deleteAllExpenses();
      setState(() {
        stats = ExpenseStats([]); // Reset the stats to empty list
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All expenses have been deleted'),
        ),
      );
    } catch (e) {
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

    // Handle no expenses case
    if (totalExpense == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

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
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                const SizedBox(width: 25),
                _buildLegend(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildTotalBar(totalExpense),
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
      radius: 20,
      showTitle: false,
    );
  }

  Widget _buildLegend() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendItem(color: Colors.blue, label: 'Tire'),
        _LegendItem(color: Colors.orange, label: 'Oil'),
        _LegendItem(color: Colors.purple, label: 'Brake Pads'),
        _LegendItem(color: Colors.green, label: 'Other'),
      ],
    );
  }

  Widget _buildTotalBar(double totalExpense) {
    final double tirePercentage =
        totalExpense > 0 ? stats.totalTireReplacement / totalExpense : 0;
    final double oilPercentage =
        totalExpense > 0 ? stats.totalOilChange / totalExpense : 0;
    final double brakePercentage =
        totalExpense > 0 ? stats.totalBrakePads / totalExpense : 0;
    final double otherPercentage =
        totalExpense > 0 ? stats.totalOther / totalExpense : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text(
            'Total Expense Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Source Sans',
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                height: 12,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildExpenseLabel(
                      ' ${stats.totalTireReplacement.toStringAsFixed(0)}',
                      Colors.blue),
                  _buildExpenseLabel(
                      ' ${stats.totalOilChange.toStringAsFixed(0)}',
                      Colors.orange),
                  _buildExpenseLabel(
                      ' ${stats.totalBrakePads.toStringAsFixed(0)}',
                      Colors.purple),
                  _buildExpenseLabel(
                      ' ${stats.totalOther.toStringAsFixed(0)}', Colors.green),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

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

  Widget _buildTotalExpenseRectangle(double totalExpense) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Cost ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Noticia',
              color: Color.fromARGB(255, 208, 157, 157),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
            decoration: BoxDecoration(
              color: const Color.fromARGB(131, 177, 168, 160),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.money,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Rs ${totalExpense.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Noticia',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(176, 244, 67, 54),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              onPressed: _showResetConfirmationDialog,
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
        Container(width: 12, height: 16, color: color),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ],
    );
  }
}
