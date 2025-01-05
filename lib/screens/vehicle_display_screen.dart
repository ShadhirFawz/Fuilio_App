import 'package:flutter/material.dart';
import 'package:fuilio_app/screens/expense_list.dart';
import 'package:fuilio_app/screens/refuel_list.dart';

class VehicleDisplayScreen extends StatelessWidget {
  final String vehicleId;
  final String vehicleName;
  final String vehicleModel;
  final String userId; // userId is defined here

  const VehicleDisplayScreen({
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleModel,
    required this.userId, // Make sure userId is passed
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(vehicleName,
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
              Text(vehicleModel,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          backgroundColor:
              Colors.transparent, // Make AppBar background transparent
          elevation: 0, // Remove the shadow
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 150, 96, 146), // Example gradient color 1
                  Color.fromARGB(255, 9, 33, 129), // Example gradient color 2
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.local_gas_station), text: 'Refuels'),
              Tab(icon: Icon(Icons.monetization_on), text: 'Expenses'),
            ],
            labelColor: Colors.white, // White text for the selected tab
            unselectedLabelColor:
                Colors.white70, // Lighter text for unselected tabs
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 0, 0), // First gradient color
                Color.fromARGB(255, 0, 0, 0), // Second gradient color
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: TabBarView(
            children: [
              RefuelList(
                vehicleId: vehicleId,
                userId: userId,
              ),
              ExpenseList(
                vehicleId: vehicleId,
                userId: userId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
