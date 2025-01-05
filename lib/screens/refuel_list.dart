import 'package:flutter/material.dart';
import '../services/refuel_service.dart';
import '../models/refuel_model.dart';
import 'add_refuel_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
              Color.fromRGBO(51, 48, 91, 1),
              Color.fromARGB(255, 26, 76, 214),
            ],
          ),
        ),
        child: SingleChildScrollView(
          // Makes the entire screen scrollable
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

              // Fuel Economy and Toggle Section
              FutureBuilder<double>(
                future: _averageFuelEconomyFuture,
                builder: (context, results) {
                  if (results.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (results.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error: ${results.error}'),
                    );
                  }

                  double averageFuelEconomy = results.data ?? 0.0;
                  bool isKmPerLitre = true;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      double percent =
                          (averageFuelEconomy / 100).clamp(0.0, 1.0);
                      double displayedValue = isKmPerLitre
                          ? averageFuelEconomy
                          : (averageFuelEconomy * 2.352);

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Average Fuel Economy',
                              style:
                                  TextStyle(fontSize: 22, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            CircularPercentIndicator(
                              radius: 90.0,
                              lineWidth: 20.0,
                              percent: percent,
                              center: Text(
                                '${displayedValue.toStringAsFixed(2)}\n${isKmPerLitre ? "Km/L" : "MPG"}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Mulish',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              progressColor: Colors.orangeAccent,
                              backgroundColor: Colors.grey,
                            ),
                            const SizedBox(height: 16),

                            // Toggle Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Km/L',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                                Switch(
                                  value: !isKmPerLitre,
                                  onChanged: (value) {
                                    setState(() {
                                      isKmPerLitre = !value;
                                    });
                                  },
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.blue,
                                ),
                                const Text('MPG',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              // Refuel Records Section (Scrollable)
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.6, // Fix height for the list to scroll properly
                child: FutureBuilder<List<Refuel>>(
                  future: _refuelsFuture,
                  builder: (context, results) {
                    if (results.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (results.hasError) {
                      return Center(child: Text('Error: ${results.error}'));
                    }

                    if (!results.hasData || results.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No refuel records.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final refuels = results.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: refuels.length,
                      itemBuilder: (context, index) {
                        final refuel = refuels[index];
                        final reversedIndex = refuels.length - index;

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
                                        color: Colors.blueAccent,
                                        size: 36,
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.orangeAccent,
                                              width: 4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${refuel.fuelAdded.toInt()}L',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orangeAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'R$reversedIndex',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          Text(
                                            '${refuel.mileage} Km',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Positioned Options Icon and Date
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'delete') {
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
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 15,
                                                    fontFamily:
                                                        'Times New Roman',
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 15,
                                                    fontFamily:
                                                        'Times New Roman',
                                                  ),
                                                ),
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
                                                    'Failed to delete refuel: $e'),
                                              ),
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
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 16,
                                  child: Text(
                                    refuel.dateTime
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0],
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddRefuel,
        tooltip: 'Add Refuel',
        child: const Icon(Icons.add),
      ),
    );
  }
}
