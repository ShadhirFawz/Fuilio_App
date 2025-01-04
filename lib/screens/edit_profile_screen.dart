import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  // Load user data for editing
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data into the form fields
  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _cityController.text = data['city'] ?? '';
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error loading user data: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Update the user's profile in Firestore
  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phone,
    required String city,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update the user's information in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
          'email': email,
          'phone': phone,
          'city': city,
        });

        Fluttertoast.showToast(
          msg: "Profile updated successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Optionally, navigate back to the previous screen
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        throw Exception("No user is logged in");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating profile: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Save the updated profile
  Future<void> _saveProfile() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String city = _cityController.text;

    // Check for empty fields
    if (name.isEmpty || email.isEmpty || phone.isEmpty || city.isEmpty) {
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
      // Get current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Update user information in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
          'email': email,
          'phone': phone,
          'city': city,
        });

        // Display success message
        Fluttertoast.showToast(
          msg: "Profile updated successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Optionally, navigate to another screen or go back
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontFamily: 'Rufina', color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow for seamless look
      ),
      body: Container(
        // Apply gradient background
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white), // Text color
                  textCapitalization: TextCapitalization.words, // Capitalize
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // City Field
                TextFormField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'City',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your city' : null,
                ),
                const SizedBox(height: 20),
                // Save Changes Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _saveProfile,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
