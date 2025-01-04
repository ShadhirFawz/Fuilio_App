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
      extendBodyBehindAppBar: true, // Extend the body behind the app bar
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Make the AppBar fully transparent
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors
                .white), // Back icon color white // Remove the shadow for a cleaner look
      ),
      body: Stack(
        children: [
          // Background Image (covers the entire screen including app bar area)
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboard_placeholder.png', // Replace with your image path
              fit: BoxFit.cover, // Cover the whole screen
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset(
                        'assets/icons/LogoFill.png', // Keep your logo here
                        height: 70,
                        fit: BoxFit.cover,
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
                      child: const Text(
                        'Fuilio',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rufina',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
