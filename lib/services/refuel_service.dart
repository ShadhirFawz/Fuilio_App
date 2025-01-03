import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuilio_app/services/expense_service.dart';
import '../models/refuel_model.dart';

class RefuelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  final String vehicleId;

  RefuelService({required this.userId, required this.vehicleId});

  Future<void> addRefuel(Refuel refuel) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('refuels')
        .doc(refuel.refuelId)
        .set(refuel.toMap());
  }

  Future<List<Refuel>> getRefuels(String vehicleId) async {
    try {
      final results = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('refuels')
          .orderBy('dateTime',
              descending: true) // DateTime sort in descending order
          .get();

      return results.docs.map((doc) => Refuel.fromMap(doc.data())).toList();
    } catch (e) {
      logger.e('Error fetching refuels: $e');
      return [];
    }
  }

  Future<double> calculateAverageFuelEconomy(String vehicleId) async {
    try {
      // Fetch refuels sorted by dateTime descending
      final refuels = await getRefuels(vehicleId);

      // Ensure there are at least two refuels for comparison
      if (refuels.length < 2) return 0.0;

      // Sort to ensure correct order (most recent first)
      refuels.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      // Take the two most recent refuels
      final recentRefuel = refuels[0];
      final previousRefuel = refuels[1];

      // Calculate distance traveled between the two refuels
      double distanceTravelled = recentRefuel.mileage - previousRefuel.mileage;

      // Fuel added in the most recent refuel
      double fuelAdded = recentRefuel.fuelAdded;

      // Calculate km/L: Distance ÷ Fuel
      return fuelAdded == 0 ? 0.0 : distanceTravelled / fuelAdded;
    } catch (e) {
      logger.e('Error calculating fuel economy: $e');
      return 0.0;
    }
  }

  Future<void> removeRefuel(String refuelId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('refuels')
          .doc(refuelId)
          .delete();
    } catch (e) {
      logger.e('Error removing refuel: $e');
      rethrow;
    }
  }
}
