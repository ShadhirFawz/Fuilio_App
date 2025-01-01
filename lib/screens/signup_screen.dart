import 'package:flutter/material.dart';
import 'package:fuilio_app/widgets/button.dart';
import 'package:fuilio_app/widgets/text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //for controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              width: double.infinity,
              height: height / 2.7,
              child: Image.asset(""),
            ),
            TextFieldInputs(
                textEditingController: emailController,
                hintText: "Enter Your Email",
                icon: Icons.email),
            TextFieldInputs(
                textEditingController: passwordController,
                hintText: "Enter Your Password",
                icon: Icons.lock),
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
            ComButton(onTap: () {}, text: "Log In"),
            SizedBox(height: height / 15),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                "Don't have an Account!",
                style: TextStyle(fontSize: 16),
              ),
              GestureDetector(
                onTap: () {},
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
