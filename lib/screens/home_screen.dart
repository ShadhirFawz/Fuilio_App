import 'package:flutter/material.dart';
import 'package:fuilio_app/screens/login_screen.dart';
import '../models/vehicle_model.dart';
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
  }

  void _loadVehicles() {
    setState(() {
      _vehiclesFuture = _vehicleService.getVehicles();
    });
  }

  void _deleteVehicle(String vehicleId) async {
    await _vehicleService
        .deleteVehicle(vehicleId); // Ensure this function is implemented
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
        builder: (context) => const LoginSignup(),
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
                _deleteVehicle(
                    vehicle.vehicleId); // Trigger delete functionality
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
      ),
      drawer: Drawer(
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
                          color: Colors.grey.shade300,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                  MaterialPageRoute(builder: (context) => const LoginSignup()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(51, 48, 91, 1),
              Color.fromARGB(255, 26, 76, 214),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),
              const Text(
                'Your Vehicles',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
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
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              ListTile(
                                title: Text(
                                  vehicle.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      fontFamily: 'Rufina'),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      'Model: ${vehicle.model}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Mulish',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      'Year: ${vehicle.manufactureYear}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Noticia',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VehicleDisplayScreen(
                                        vehicleId: vehicle.vehicleId,
                                        vehicleName: vehicle.name,
                                        vehicleModel: vehicle.model,
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _showOptionsMenu(context, vehicle);
                                  },
                                ),
                              ),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Text(
                                  ' ${vehicle.vehicleDate.toLocal().toString().split(' ')[0]}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddVehicle,
        child: const Icon(Icons.add),
      ),
    );
  }
}
