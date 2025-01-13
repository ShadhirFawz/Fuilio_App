import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/refuel_model.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
import 'package:logger/logger.dart';
import 'local_notification_service.dart';

final logger = Logger();

class RefuelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  final String vehicleId;
  final NotificationService _notificationService;
  final LocalNotificationService _localNotificationService;

  RefuelService({required this.userId, required this.vehicleId})
      : _notificationService = NotificationService(userId: userId),
        _localNotificationService = LocalNotificationService();

  Future<void> addRefuel(Refuel refuel) async {
    try {
      // Add refuel data
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('refuels')
          .doc(refuel.refuelId)
          .set(refuel.toMap());

      // Trigger service notification logic
      await _checkForServiceNotification(refuel.mileage);
    } catch (e) {
      logger.e('Error adding refuel: $e');
    }
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

  Future<void> _checkForServiceNotification(double mileage) async {
    try {
      // Fetch last saved service mileage or initialize to 0 if not present
      final lastServiceDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .get();

      int lastServiceMileage =
          lastServiceDoc.data()?['lastServiceMileage'] ?? 0;

      // Calculate predictive mileage (mileage + 100km)
      final predictiveMileage = mileage + 100;

      // Check if predictive mileage has crossed the next service interval (500km increment)
      if (predictiveMileage >= (lastServiceMileage + 500)) {
        final serviceMileage = lastServiceMileage + 500;

        // Add Firestore notification
        await _notificationService.addNotification(
          vehicleId: vehicleId,
          notification: NotificationModel(
            notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
            message:
                "Your vehicle service for Vehicle $vehicleId is nearby. Stay notified.",
            read: false,
            createdAt: DateTime.now(),
            serviceMileage: serviceMileage,
          ),
        );

        // Trigger local notification
        await _localNotificationService.showNotification(
          id: serviceMileage, // Use service mileage as ID for uniqueness
          title: "Service Reminder",
          body:
              "Your vehicle service for Vehicle $vehicleId is nearby. Stay notified.",
          payload: vehicleId, // Pass the vehicle ID as payload for future use
        );

        // Update last service mileage in Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('vehicles')
            .doc(vehicleId)
            .update({'lastServiceMileage': serviceMileage});
      }
    } catch (e) {
      logger.e('Error checking for service notification: $e');
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
