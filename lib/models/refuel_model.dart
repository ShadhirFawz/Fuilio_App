import 'package:cloud_firestore/cloud_firestore.dart';

class Refuel {
  final String refuelId;
  final String vehicleId;
  final double mileage;
  final double fuelAdded;
  final DateTime dateTime; // Renamed from 'date' to 'dateTime'

  Refuel({
    required this.refuelId,
    required this.vehicleId,
    required this.mileage,
    required this.fuelAdded,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'refuelId': refuelId,
      'vehicleId': vehicleId,
      'mileage': mileage,
      'fuelAdded': fuelAdded,
      'dateTime': dateTime, // Updated key name
    };
  }

  factory Refuel.fromMap(Map<String, dynamic> map) {
    return Refuel(
      refuelId: map['refuelId'] as String,
      vehicleId: map['vehicleId'] as String,
      mileage: (map['mileage'] as num).toDouble(),
      fuelAdded: (map['fuelAdded'] as num).toDouble(),
      dateTime: (map['dateTime'] as Timestamp).toDate(), // Updated key name
    );
  }
}
