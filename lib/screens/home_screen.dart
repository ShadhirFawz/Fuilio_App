import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuilio_app/screens/edit_profile_screen.dart';
import 'package:fuilio_app/screens/login_screen.dart';
import 'package:fuilio_app/screens/notification_list_screen.dart';
import '../models/vehicle_model.dart';
import 'package:badges/badges.dart' as custom_badge;
import '../services/auth_service.dart';
import '../services/vehicle_service.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_display_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({required this.userId, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VehicleService _vehicleService;
  late Future<List<Vehicle>> _vehiclesFuture;
  final AuthServices _authServices = AuthServices();

  @override
  void initState() {
    super.initState();
    _vehicleService = VehicleService(userId: widget.userId);
    _loadVehicles();
    _fetchUnreadNotifications();
  }

  void _loadVehicles() {
    setState(() {
      _vehiclesFuture = _vehicleService.getVehicles();
    });
  }

  int _unreadNotificationCount = 0;

  void _fetchUnreadNotifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('vehicles')
        .get();

    int unreadCount = 0;

    for (var vehicle in snapshot.docs) {
      final notificationsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('vehicles')
          .doc(vehicle.id)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      unreadCount += notificationsSnapshot.docs.length;
    }

    setState(() {
      _unreadNotificationCount = unreadCount;
    });
  }

  void _deleteVehicle(String vehicleId) async {
    await _vehicleService.deleteVehicle(vehicleId);
    _loadVehicles();
  }

  void _navigateToAddVehicle() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVehicleScreen(vehicleService: _vehicleService),
      ),
    );
    _loadVehicles();
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, Vehicle vehicle) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context); // Close the menu
                _deleteVehicle(vehicle.vehicleId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: custom_badge.Badge(
              badgeContent: Text(
                _unreadNotificationCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              showBadge: _unreadNotificationCount > 0,
              child: const Icon(
                Icons.notifications,
                size: 30,
                color: Colors.black,
              ),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationListScreen(userId: widget.userId),
                ),
              );
              _fetchUnreadNotifications(); // Refresh count after returning from notification screen
            },
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 16, // Added elevation for the drawer
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE0E0E0),
                Color.fromARGB(255, 143, 154, 160),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE0E0E0),
                      Color(0xFFB0BEC5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: FutureBuilder<String?>(
                  future: _authServices.getUserName(),
                  builder: (context, results) {
                    final userName = results.data ?? 'User';
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 188, 99, 99),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 9),
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              colors: [Color(0xFF5B57CC), Color(0xFFDA5037)],
                              stops: [0.0, 0.63],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds);
                          },
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontFamily: 'Rufina',
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: _navigateToEditProfile,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await _authServices.logOut(context: context);
                  Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginSignup()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(51, 48, 91, 1),
              Color.fromARGB(181, 77, 13, 149),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 100), // Adjusted spacing after AppBar
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Your Vehicles',
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
                height: 16), // Minimal spacing between title and list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12), // Adjust corner radius
                child: Image.asset(
                  'assets/images/home_img.png', // Replace with your image URL
                  height: 200, // Adjust height as needed
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16), // Spacing after the image
            Expanded(
              child: FutureBuilder<List<Vehicle>>(
                future: _vehiclesFuture,
                builder: (context, results) {
                  if (results.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (results.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${results.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  } else if (!results.hasData || results.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No vehicles added yet.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final vehicles = results.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.directions_car,
                              color: Colors.brown,
                              size: 40,
                            ),
                            title: Text(
                              vehicle.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Rufina',
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Model: ${vehicle.model}',
                                  style: const TextStyle(
                                    fontFamily: 'Mulish',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Year: ${vehicle.manufactureYear}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                _showOptionsMenu(context, vehicle);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VehicleDisplayScreen(
                                    vehicleId: vehicle.vehicleId,
                                    vehicleName: vehicle.name,
                                    vehicleModel: vehicle.model,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddVehicle,
        child: const Icon(Icons.add),
      ),
    );
  }
}
