import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleService vehicleService;

  const AddVehicleScreen({required this.vehicleService, super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  void _addVehicle() async {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        vehicleId: const Uuid().v4(),
        name: _nameController.text.trim(),
        model: _modelController.text.trim(),
        manufactureYear: int.parse(_yearController.text.trim()),
        vehicleDate: DateTime.now(),
      );

      await widget.vehicleService.addVehicle(vehicle);

      // Show success and navigate back
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle added successfully!')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      appBar: AppBar(
        title: const Text(
          'Add Vehicle',
          style: TextStyle(fontFamily: 'Rufina', color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow for seamless look
      ),
      body: Container(
        // Apply gradient background
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Vehicle Name Field
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white), // Text color
                  textCapitalization:
                      TextCapitalization.characters, // Uppercase first letters
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Name',
                    labelStyle: TextStyle(color: Colors.white70), // Label color
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white70), // Default border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.white), // Focused border
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                // Model Field
                TextFormField(
                  controller: _modelController,
                  style: const TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the model' : null,
                ),
                const SizedBox(height: 16),
                // Manufacture Year Field
                TextFormField(
                  controller: _yearController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Manufacture Year',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final year = int.tryParse(value!);
                    if (year == null ||
                        year < 1886 ||
                        year > DateTime.now().year) {
                      return 'Enter a valid year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Add Vehicle Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    foregroundColor: Colors.black, // Button text color
                  ),
                  onPressed: _addVehicle,
                  child: const Text('Add Vehicle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
