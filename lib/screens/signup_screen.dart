import 'package:flutter/material.dart';
import 'package:fuilio_app/screens/login_screen.dart';
import 'package:fuilio_app/services/auth_service.dart';
import 'package:fuilio_app/widgets/button.dart';
import 'package:fuilio_app/widgets/text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for the input fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  // Method to handle user signup
  void signUpUser() async {
    setState(() {
      isLoading = true;
    });

    // Call the signup method from AuthService
    await AuthServices().signup(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
      city: cityController.text,
      phone: phoneController.text,
      context: context,
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Added to enable scrolling
          child: SizedBox(
            height: height, // Ensures content fits within the screen height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Align content
              children: [
                SizedBox(
                  width: double.infinity,
                  height: height / 15,
                  child: Image.asset(""), // Add your image asset path
                ),
                // Name field
                TextFieldInputs(
                  textEditingController: nameController,
                  hintText: "Enter your name",
                  icon: Icons.person,
                ),
                // Email field
                TextFieldInputs(
                  textEditingController: emailController,
                  hintText: "Enter your email",
                  icon: Icons.email,
                ),
                // Password field
                TextFieldInputs(
                  textEditingController: passwordController,
                  hintText: "Enter your password",
                  icon: Icons.lock,
                  isPass: true,
                ),
                // City field
                TextFieldInputs(
                  textEditingController: cityController,
                  hintText: "Enter your city",
                  icon: Icons.location_city,
                ),
                // Phone number field
                TextFieldInputs(
                  textEditingController: phoneController,
                  hintText: "Enter your phone number",
                  icon: Icons.phone,
                ),
                // Sign Up Button
                isLoading
                    ? const CircularProgressIndicator()
                    : ComButton(onTap: signUpUser, text: "Sign Up"),
                SizedBox(height: height / 15),
                // Login redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account!",
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginSignup(),
                          ),
                        );
                      },
                      child: const Text(
                        "  Log In",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
