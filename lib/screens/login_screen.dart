import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuilio_app/screens/home_screen.dart';
import 'package:fuilio_app/screens/signup_screen.dart';
import 'package:fuilio_app/services/auth_service.dart';
import 'package:fuilio_app/widgets/button.dart';
import 'package:fuilio_app/widgets/text_field.dart';

class LoginSignup extends StatefulWidget {
  const LoginSignup({super.key});

  @override
  State<LoginSignup> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<LoginSignup> {
  //for controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void logInUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Log in the user and check success
      bool isLoggedIn = await AuthServices().logIn(
        email: emailController.text,
        password: passwordController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (isLoggedIn) {
        // Get the logged-in user's ID and navigate to the HomeScreen
        final userId = AuthServices().getCurrentUserId();

        // Navigate to the HomeScreen and pass the userId
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: userId),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "An unexpected error occurred. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // Remove shadow for a cleaner look
        iconTheme:
            const IconThemeData(color: Colors.white), // Back icon color white
      ),
      body: Stack(
        children: [
          // Background Image (covers the entire screen including app bar area)
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboard_placeholder.png', // Your background image path
              fit: BoxFit.cover,
              width: 200,
              height: 200, // Cover the whole screen
            ),
          ),
          // Content Overlay
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                    height: 70), // To push the content below the AppBar
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    'assets/icons/LogoFill.png', // Keep your LogoFill here
                    height: 150,
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
                const SizedBox(height: 25),
                const Text('Log In',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Rufina',
                        color: Colors.white)),
                const SizedBox(height: 20),
                TextFieldInputs(
                  icon: Icons.person,
                  textEditingController: emailController,
                  hintText: 'Enter your email',
                ),
                TextFieldInputs(
                  icon: Icons.lock,
                  textEditingController: passwordController,
                  hintText: 'Enter your password',
                  isPass: true,
                ),
                ComButton(onTap: logInUser, text: "Log In"),
                SizedBox(height: height / 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an Account!",
                        style: TextStyle(fontSize: 16)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        " Signup",
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
        ],
      ),
    );
  }
}
