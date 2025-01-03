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
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('refuels')
          .orderBy('date',
              descending: true) // DateTime sort in descending order
          .get();

      return snapshot.docs.map((doc) => Refuel.fromMap(doc.data())).toList();
    } catch (e) {
      logger.e('Error fetching refuels: $e');
      return [];
    }
  }

  Future<double> calculateAverageFuelEconomy(String vehicleId) async {
    try {
      final refuels = await getRefuels(vehicleId);

      if (refuels.length < 2) return 0.0;

      // Sort by date and time in descending order
      refuels.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      double totalFuel = 0.0;
      double totalMileage = 0.0;

      for (int i = 1; i < refuels.length; i++) {
        totalFuel += refuels[i].fuelAdded;
        totalMileage += refuels[i].mileage - refuels[i - 1].mileage;
      }

      return totalFuel == 0 ? 0.0 : totalMileage / totalFuel;
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
