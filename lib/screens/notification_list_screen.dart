import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationListScreen extends StatelessWidget {
  final String userId;

  const NotificationListScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // To allow the gradient to extend behind the AppBar
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
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('vehicles')
                .get(),
            builder: (context, vehicleSnapshot) {
              if (!vehicleSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final vehicleDocs = vehicleSnapshot.data!.docs;

              return ListView.builder(
                itemCount: vehicleDocs.length,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  final vehicleId = vehicleDocs[index].id;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('vehicles')
                        .doc(vehicleId)
                        .collection('notifications')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, notificationSnapshot) {
                      if (!notificationSnapshot.hasData) {
                        return const SizedBox();
                      }

                      final notifications = notificationSnapshot.data!.docs
                          .map((doc) => NotificationModel.fromMap(
                              doc.data() as Map<String, dynamic>))
                          .toList();

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpansionTile(
                          title: Text(
                            'Vehicle: $vehicleId',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: notifications.map((notification) {
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: ListTile(
                                title: Text(
                                  notification.message,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Created at: ${notification.createdAt.toString()}',
                                ),
                                trailing: notification.read
                                    ? const Icon(Icons.check,
                                        color: Colors.green)
                                    : const Icon(Icons.circle,
                                        color: Colors.red),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
