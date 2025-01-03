import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  final String userId; // User ID for accessing specific user data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VehicleService({required this.userId});

  // Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    final vehicleCollection =
        _firestore.collection('users').doc(userId).collection('vehicles');
    await vehicleCollection.doc(vehicle.vehicleId).set(vehicle.toJson());
  }

  // Fetch all vehicles for the user
  Future<List<Vehicle>> getVehicles() async {
    final vehicleCollection =
        _firestore.collection('users').doc(userId).collection('vehicles');
    final results = await vehicleCollection.get();

    return results.docs.map((doc) => Vehicle.fromJson(doc.data())).toList();
  }

  // Fetch a specific vehicle by ID
  Future<Vehicle?> getVehicle(String vehicleId) async {
    final vehicleDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId);
    final results = await vehicleDoc.get();

    if (results.exists) {
      return Vehicle.fromJson(results.data()!);
    }
    return null;
  }

  // Delete a vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    final vehicleDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId);
    await vehicleDoc.delete();
  }
}
