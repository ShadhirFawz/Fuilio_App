// Model for Notification
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String message;
  final bool read;
  final DateTime createdAt;
  final int serviceMileage;

  NotificationModel({
    required this.notificationId,
    required this.message,
    required this.read,
    required this.createdAt,
    required this.serviceMileage,
  });

  // Convert Firestore document to NotificationModel
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'] as String,
      message: map['message'] as String,
      read: map['read'] as bool,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      serviceMileage: map['serviceMileage'] as int,
    );
  }

  // Convert NotificationModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'message': message,
      'read': read,
      'createdAt': createdAt,
      'serviceMileage': serviceMileage,
    };
  }
}
