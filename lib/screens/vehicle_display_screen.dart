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
                  style: const TextStyle(
                      fontSize: 18, color: Color.fromARGB(255, 0, 0, 0))),
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
                  Color.fromARGB(206, 194, 40, 40),
                  Color.fromARGB(206, 194, 40, 40), // Example gradient color 2
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.local_gas_station), text: 'Refuels'),
              Tab(icon: Icon(Icons.monetization_on), text: 'Expenses'),
            ],
            labelColor:
                Color.fromARGB(255, 0, 0, 0), // White text for the selected tab
            unselectedLabelColor: Color.fromARGB(
                255, 115, 92, 115), // Lighter text for unselected tabs
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
