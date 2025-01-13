import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  NotificationService({required this.userId});

  // Add a new notification
  Future<void> addNotification({
    required String vehicleId,
    required NotificationModel notification,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('notifications')
          .doc(notification.notificationId)
          .set(notification.toMap());
    } catch (e) {
      logger.e('Error adding notification: $e');
    }
  }

  // Fetch notifications for a specific vehicle
  Future<List<NotificationModel>> getNotifications(String vehicleId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      logger.e('Error fetching notifications: $e');
      return [];
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String vehicleId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'read': true});
      }
    } catch (e) {
      logger.e('Error marking notifications as read: $e');
    }
  }

  // Delete all notifications for a vehicle
  Future<void> deleteNotifications(String vehicleId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vehicles')
          .doc(vehicleId)
          .collection('notifications')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      logger.e('Error deleting notifications: $e');
    }
  }
}
