import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuilio_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuilio_app/screens/login_screen.dart';
import 'package:fuilio_app/screens/onboard.dart'; // Your onboarding screens
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For checking user state
import 'package:logger/logger.dart'; // Import logger package

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widgets are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fuilio App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start with a splash screen
    );
  }
}

// Splash Screen to Decide Initial Route
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Logger _logger = Logger(); // Initialize logger

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialRoute();
    });
  }

  Future<void> _checkInitialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      final currentUser = FirebaseAuth.instance.currentUser;

      // Log values to check
      _logger.d('hasSeenOnboarding: $hasSeenOnboarding');
      _logger.d('currentUser: $currentUser');

      // Determine navigation based on user's state
      Widget nextScreen;
      if (currentUser != null) {
        // User is logged in
        nextScreen = const HomeScreen(); // Replace with your home screen
      } else if (!hasSeenOnboarding) {
        // Show onboarding for first-time users
        nextScreen = const Onboarding();
      } else {
        // Show login/signup for returning users
        nextScreen = const LoginSignup();
      }

      // Navigate to the determined screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      }
    } catch (e) {
      // Handle potential errors (e.g., Firebase or SharedPreferences failures)
      _logger.e('Error determining initial route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
