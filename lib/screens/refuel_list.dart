import 'package:flutter/material.dart';
import '../services/refuel_service.dart';
import '../models/refuel_model.dart';
import 'add_refuel_screen.dart';

class RefuelList extends StatefulWidget {
  final String vehicleId;
  final String userId;

  const RefuelList({required this.vehicleId, required this.userId, super.key});

  @override
  State<RefuelList> createState() => _RefuelListState();
}

class _RefuelListState extends State<RefuelList> {
  late RefuelService _refuelService;
  late Future<List<Refuel>> _refuelsFuture;
  late Future<double> _averageFuelEconomyFuture;

  @override
  void initState() {
    super.initState();
    _refuelService =
        RefuelService(userId: widget.userId, vehicleId: widget.vehicleId);
    _refuelsFuture = _refuelService.getRefuels(widget.vehicleId);
    _averageFuelEconomyFuture =
        _refuelService.calculateAverageFuelEconomy(widget.vehicleId);
  }

  void _navigateToAddRefuel() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRefuelScreen(
          userId: widget.userId,
          vehicleId: widget.vehicleId,
        ),
      ),
    );
    // Refresh the data after returning from AddRefuelScreen
    setState(() {
      _refuelsFuture = _refuelService.getRefuels(widget.vehicleId);
      _averageFuelEconomyFuture =
          _refuelService.calculateAverageFuelEconomy(widget.vehicleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(51, 48, 91, 1), // Light Blue
              Color.fromARGB(255, 26, 76, 214), // Soft Blue
            ],
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Refuel Records',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Times New Roman',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            FutureBuilder<double>(
              future: _averageFuelEconomyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final averageFuelEconomy = snapshot.data ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Average Fuel Economy: ${averageFuelEconomy.toStringAsFixed(2)} Km/L',
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                );
              },
            ),
            Expanded(
              child: FutureBuilder<List<Refuel>>(
                future: _refuelsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                      'No refuel records.',
                      style: TextStyle(color: Colors.white),
                    ));
                  }

                  final refuels = snapshot.data!;
                  return ListView.builder(
                    itemCount: refuels.length,
                    itemBuilder: (context, index) {
                      final refuel = refuels[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.local_gas_station,
                                      color: Colors
                                          .blueAccent, // Refuel icon color
                                      size: 36,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Fuel Added: ${refuel.fuelAdded} liters',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Mileage: ${refuel.mileage} km',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              refuel
                                                  .dateTime // Updated from `date`
                                                  .toLocal()
                                                  .toString()
                                                  .split(' ')[0],
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                  top: 8,
                                  right: 8,
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'delete') {
                                        // Confirm deletion
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: const Text(
                                                'Are you sure you want to delete this refuel record?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          try {
                                            await _refuelService
                                                .removeRefuel(refuel.refuelId);
                                            setState(() {
                                              _refuelsFuture = _refuelService
                                                  .getRefuels(widget.vehicleId);
                                              _averageFuelEconomyFuture =
                                                  _refuelService
                                                      .calculateAverageFuelEconomy(
                                                          widget.vehicleId);
                                            });
                                          } catch (e) {
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to delete refuel: $e')),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.grey,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddRefuel,
        tooltip: 'Add Refuel',
        child: const Icon(Icons.add),
      ),
    );
  }
}
