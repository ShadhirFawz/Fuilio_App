import 'package:flutter/material.dart';
import 'package:fuilio_app/screens/expense_list.dart';
import 'package:fuilio_app/screens/refuel_list.dart';

class VehicleDisplayScreen extends StatelessWidget {
  final String vehicleId;
  final String vehicleName;
  final String vehicleModel;
  final String userId;

  const VehicleDisplayScreen({
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleModel,
    required this.userId,
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
              Text(
                vehicleName,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Text(
                vehicleModel,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent, // Transparent AppBar background
          elevation: 0, // Remove shadow
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(206, 194, 40, 40), // Gradient start
                  Color.fromARGB(206, 194, 40, 40), // Gradient end
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
            labelColor: Color.fromARGB(255, 0, 0, 0), // Selected tab text color
            unselectedLabelColor: Color.fromARGB(255, 115, 92, 115),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 0, 0), // Gradient start
                Color.fromARGB(255, 0, 0, 0), // Gradient end
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: TabBarView(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(
                          206, 194, 40, 40), // TabView gradient start
                      Color.fromARGB(255, 0, 0, 0), // TabView gradient end
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: RefuelList(
                  vehicleId: vehicleId,
                  userId: userId,
                  vehicleName: vehicleName,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(
                          206, 194, 40, 40), // TabView gradient start
                      Color.fromARGB(255, 0, 0, 0), // TabView gradient end
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ExpenseList(
                  vehicleId: vehicleId,
                  userId: userId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
