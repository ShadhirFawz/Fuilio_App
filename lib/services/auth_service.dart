import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuilio_app/screens/login_screen.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up a new user
  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String city,
    required String phone,
    required BuildContext context,
  }) async {
    // Check for empty fields
    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        city.isEmpty ||
        phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields."),
          backgroundColor: Colors.black54,
        ),
      );
      return; // Stop further execution
    }

    // Validate email format
    String emailPattern = r'^[^@]+@[^@]+\.[^@]+$';
    RegExp emailRegExp = RegExp(emailPattern);

    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email address. Please enter a valid email."),
          backgroundColor: Colors.black54,
        ),
      );
      return; // Stop further execution
    }

    // Validate password (minimum 6 characters)
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters long."),
          backgroundColor: Colors.black54,
        ),
      );
      return; // Stop further execution
    }

    // Validate phone number (exactly 10 digits)
    String phonePattern = r'^[0-9]{10}$';
    RegExp phoneRegExp = RegExp(phonePattern);

    if (!phoneRegExp.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Invalid phone number. Please enter a 10-digit phone number."),
          backgroundColor: Colors.black54,
        ),
      );
      return; // Stop further execution
    }

    try {
      // Register the user using Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Save user information in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'city': city,
          'phone': phone,
          'userId': user.uid,
        });

        // Display a success toast
        Fluttertoast.showToast(
          msg: "Sign-up successful!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Navigate to the LoginSignup screen
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const LoginSignup()),
        );
      }
    } catch (e) {
      // General error handling
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Sign in an existing user
  Future<bool> logIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter both email and password.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    try {
      // Authenticate the user
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      Fluttertoast.showToast(
        msg: "Login successful!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return true; // Login successful
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else {
        message = "Something went wrong. Please try again.";
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false; // Login failed
    } catch (e) {
      log("Error during signin: ${e.toString()}");
      return false; // Login failed
    }
  }

  // Sign out the current user
  Future<void> logOut({
    required BuildContext context,
  }) async {
    try {
      await _auth.signOut();

      Fluttertoast.showToast(
        msg: "Logout successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginSignup()),
      );
    } catch (e) {
      log("Error during signout: ${e.toString()}");
    }
  }

  // Fetch the user's name from Firestore
  Future<String?> getUserName() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        // Check if the document exists and has the "name" field
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          return data['name'] ?? 'No Name Found';
        } else {
          log("Document for user does not exist or has no name field.");
        }
      } else {
        log("No logged-in user.");
      }
    } catch (e) {
      log("Error fetching user name: ${e.toString()}");
    }
    return null;
  }

  // Get the current user's ID
  String getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }
}
