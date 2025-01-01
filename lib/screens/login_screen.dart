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

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void logInUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Call the Login method from AuthService
      await AuthServices().logIn(
        email: emailController.text,
        password: passwordController.text,
        context: context,
      );

      // If the LogIn was successful, navigate to the WelcomeScreen
      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      // If there was an error during signup, show error and stop loading
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "LogIn failed. Please try again.",
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
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SizedBox(
        child: Column(
          children: [
            SizedBox(
              height: height / 2.7,
              child: Image.asset('images/login.jpg'),
            ),
            TextFieldInputs(
              icon: Icons.person,
              textEditingController: emailController,
              hintText: 'Enter your email',
            ),
            TextFieldInputs(
              icon: Icons.lock,
              textEditingController: passwordController,
              hintText: 'Enter your passord',
              isPass: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 35,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forget Password?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            ComButton(onTap: logInUser, text: "Log In"),
            SizedBox(height: height / 15),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                "Don't have an Account!",
                style: TextStyle(fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  "  Signup",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )
            ])
          ],
        ),
      )),
    );
  }
}
