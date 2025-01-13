import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/refuel_service.dart';
import '../models/refuel_model.dart';
import 'add_refuel_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class RefuelList extends StatefulWidget {
  final String vehicleId;
  final String userId;
  final String vehicleName;

  const RefuelList({
    required this.vehicleId,
    required this.userId,
    super.key,
    required this.vehicleName,
  });

  @override
  State<RefuelList> createState() => _RefuelListState();
}

class _RefuelListState extends State<RefuelList> {
  late RefuelService _refuelService;
  late Future<List<Refuel>> _refuelsFuture;
  late Future<double> _averageFuelEconomyFuture;

  double? _lastSavedAverageFuelEconomy;
  DateTime? _lastSavedDate;
  bool isKmPerLitre = true; // This tracks the conversion state

  @override
  void initState() {
    super.initState();
    _refuelService =
        RefuelService(userId: widget.userId, vehicleId: widget.vehicleId);
    _loadHistory();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _refuelsFuture = _refuelService.getRefuels(widget.vehicleId);
      _averageFuelEconomyFuture =
          _refuelService.calculateAverageFuelEconomy(widget.vehicleId);
    });
  }

  // Function to load history from SharedPreferences
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastSavedAverageFuelEconomy =
          prefs.getDouble('last_average_fuel_economy');
      String? savedDate = prefs.getString('last_saved_date');
      if (savedDate != null) {
        _lastSavedDate = DateTime.parse(savedDate);
      }
    });
  }

  // Function to save history to SharedPreferences
  Future<void> _saveHistory(double newAverageFuelEconomy) async {
    final prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();

    // Check if the average fuel economy has actually changed
    if (_lastSavedAverageFuelEconomy != null &&
        newAverageFuelEconomy != _lastSavedAverageFuelEconomy) {
      // Store the previous average fuel economy
      await prefs.setDouble(
          'previous_average_fuel_economy', _lastSavedAverageFuelEconomy!);
      await prefs.setString('previous_saved_date', now.toIso8601String());
    }

    // Update the new value
    await prefs.setDouble('last_average_fuel_economy', newAverageFuelEconomy);
    await prefs.setString('last_saved_date', now.toIso8601String());

    setState(() {
      _lastSavedAverageFuelEconomy = newAverageFuelEconomy;
      _lastSavedDate = now;
    });
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

    // Refresh data and save the updated history
    _refreshData();
  }

  // Show History Popup
  void _showHistoryPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('AFE History'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_lastSavedAverageFuelEconomy != null &&
                  _lastSavedDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Average: ${_lastSavedAverageFuelEconomy!.toStringAsFixed(2)} Km/L',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Saved on: ${_lastSavedDate?.toLocal().toString().split(' ')[0] ?? "N/A"}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                )
              else
                const Text(
                  'No history available.',
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(51, 48, 91, 1),
              Color.fromARGB(181, 77, 13, 149),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Refuel Records',
                  style: TextStyle(
                    fontSize: 20,
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
                      padding: EdgeInsets.all(12.0),
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

                  // Save the previous history only if the fuel economy has changed
                  if (_lastSavedAverageFuelEconomy != null &&
                      _lastSavedAverageFuelEconomy != averageFuelEconomy) {
                    _saveHistory(
                        _lastSavedAverageFuelEconomy!); // Save the previous value
                  }

                  return StatefulBuilder(
                    builder: (context, setState) {
                      double percent =
                          (averageFuelEconomy / 100).clamp(0.0, 1.0);
                      double displayedValue = isKmPerLitre
                          ? averageFuelEconomy
                          : (averageFuelEconomy * 2.352);

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            const Text(
                              'Average Fuel Economy',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontFamily: 'Mulish',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularPercentIndicator(
                                  radius: 90.0,
                                  lineWidth: 20.0,
                                  percent: percent,
                                  center: Text(
                                    '${displayedValue.toStringAsFixed(2)}\n${isKmPerLitre ? "Km/L" : "M/G"}',
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
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 13.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(70, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.history,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    onPressed: _showHistoryPopup,
                                    tooltip: 'View Refuel History',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Toggle Button for fuel unit conversion
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Km/L ',
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
                                const Text(' M/G',
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
              FutureBuilder<List<Refuel>>(
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
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable internal scrolling
                    itemCount: refuels.length,
                    itemBuilder: (context, index) {
                      final refuel = refuels[index];
                      final reversedIndex = refuels.length - index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 5.0),
                        child: Opacity(
                          opacity:
                              0.9, // Adjust opacity value here, 0.0 for fully transparent, 1.0 for fully opaque
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.local_gas_station,
                                        color: Colors.blueAccent,
                                        size: 36,
                                      ),
                                      const SizedBox(width: 5),
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
                                      const SizedBox(width: 7),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'R$reversedIndex',
                                            style: const TextStyle(
                                              fontSize: 17,
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
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontFamily: 'Times New Roman',
                                            color: Colors.red,
                                          ),
                                        ),
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
                                        fontSize: 10,
                                        color:
                                            Color.fromARGB(255, 140, 122, 122)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
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
