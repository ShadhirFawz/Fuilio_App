import 'package:flutter/material.dart';
import '../widgets/expense_stats.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ExpenseStatsDisplay extends StatelessWidget {
  final ExpenseStats stats;

  const ExpenseStatsDisplay({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRing('Tire Replacement', stats.totalTireReplacement),
          const SizedBox(height: 16),
          _buildStatRing('Oil Change', stats.totalOilChange),
          const SizedBox(height: 16),
          _buildStatRing('Brake Pads', stats.totalBrakePads),
          const SizedBox(height: 16),
          _buildStatRing('Other Expenses', stats.totalOther),
          const SizedBox(height: 16),
          _buildTotalProgressBar(stats.totalSpent),
        ],
      ),
    );
  }

  // Radial Progress Ring for each expense type
  Widget _buildStatRing(String title, double amount) {
    final double progress = amount / 1000; // Just as a sample scaling factor
    return GestureDetector(
      onTap: () => _showDetails(title, amount),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Background Circle
              CircularProgressIndicator(
                value: progress > 1 ? 1.0 : progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 10.0,
              ),
              // Expense Text
              Text(
                '$title\nRs ${amount.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Total Progress Bar for all expenses
  Widget _buildTotalProgressBar(double totalSpent) {
    final double progress = totalSpent / 5000; // Total budget or target value
    return GestureDetector(
      onTap: () => _showDetails('Total Spent', totalSpent),
      child: Column(
        children: [
          Text(
            'Total Spent',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress > 1 ? 1.0 : progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rs ${totalSpent.toStringAsFixed(2)} spent',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  // OnTap to show the expense detail
  void _showDetails(String title, double amount) {
    // Optionally, you can show a dialog or navigate to another screen with more info.
    logger.i('Tapped on $title, Amount: Rs ${amount.toStringAsFixed(2)}');
  }
}
