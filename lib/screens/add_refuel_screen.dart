import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/refuel_model.dart';
import '../services/refuel_service.dart';

class AddRefuelScreen extends StatefulWidget {
  final String vehicleId;
  final String userId;

  const AddRefuelScreen({
    required this.vehicleId,
    required this.userId,
    super.key,
  });

  @override
  State<AddRefuelScreen> createState() => _AddRefuelScreenState();
}

class _AddRefuelScreenState extends State<AddRefuelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();
  final _fuelAddedController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late RefuelService _refuelService;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Initialize RefuelService with userId and vehicleId
    _refuelService = RefuelService(
      userId: widget.userId,
      vehicleId: widget.vehicleId,
    );
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _fuelAddedController.dispose();
    super.dispose();
  }

  Future<void> _saveRefuel() async {
    if (_formKey.currentState!.validate()) {
      final currentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
      );

      final refuel = Refuel(
        refuelId: _uuid.v4(),
        vehicleId: widget.vehicleId,
        mileage: double.parse(_mileageController.text),
        fuelAdded: double.parse(_fuelAddedController.text),
        dateTime: currentDateTime, // Updated from 'date' to 'dateTime'
      );

      try {
        await _refuelService.addRefuel(refuel);
        // Notify success and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Refuel added successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      appBar: AppBar(
        title: const Text(
          'Add Refuel',
          style: TextStyle(fontFamily: 'Rufina', color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0, // Remove shadow for seamless look
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(51, 48, 91, 1), // Light Blue
              Color.fromARGB(255, 26, 76, 214), // Soft Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Mileage Field
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _mileageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white), // Text color
                    decoration: const InputDecoration(
                      labelText: 'Mileage',
                      labelStyle:
                          TextStyle(color: Colors.white70), // Label color
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white70), // Default border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white), // Focused border
                      ),
                      prefixText: 'KM | ', // Add the Rs prefix
                      prefixStyle: TextStyle(
                        color: Colors.white, // Text color for the prefix
                        fontWeight: FontWeight.normal, // Optional styling
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mileage';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Fuel Added Field
                  TextFormField(
                    controller: _fuelAddedController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white), // Text color
                    decoration: const InputDecoration(
                      labelText: 'Fuel Added',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      prefixText: 'L | ', // Add the Rs prefix
                      prefixStyle: TextStyle(
                        color: Colors.white, // Text color for the prefix
                        fontWeight: FontWeight.normal, // Optional styling
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter fuel amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Date Selector Row
                  Row(
                    children: [
                      Text(
                        'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.white, // Button background color
                          foregroundColor: Colors.black, // Button text color
                        ),
                        onPressed: _pickDate,
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Save Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Button background color
                      foregroundColor: Colors.black, // Button text color
                    ),
                    onPressed: _saveRefuel,
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 5),
                  // Image Asset
                  Center(
                    child: Image.asset(
                      'assets/images/refuel_image.png', // Replace with your image asset path
                      height: 450,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
