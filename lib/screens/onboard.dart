import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuilio_app/screens/login_screen.dart';
import 'package:logger/logger.dart'; // Import logger package

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  // PageController to control the pages
  final PageController _pageController = PageController();
  int _currentIndex = 0; // Tracks the current page index
  final Logger _logger = Logger(); // Initialize logger

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    // Log to confirm setting the flag
    _logger.d('hasSeenOnboarding set to true');

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const LoginSignup()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              // Onboarding Page 1
              OnboardingPage(
                logo: 'assets/icons/LogoFill.png',
                banner: 'assets/images/onboard_placeholder.png',
                mainImage: 'assets/images/img_onboard1.png',
                title: 'FuiLio',
                subtitle: 'We value your money, even if its your vehicle',
                description: 'Do you really worried about\nyour savings!',
                footer: 'Couldnt find a safe place to track\n  your expense',
                pageIndex: 0,
                totalPages: 3,
                onNext: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              // Onboarding Page 3
              OnboardingPage(
                logo: 'assets/icons/LogoFill.png',
                banner: 'assets/images/onboard_placeholder.png',
                mainImage: 'assets/images/img_onboard2.png',
                title: 'FuiLio',
                subtitle: 'We got your expense covered',
                description: 'Trouble in having service records!',
                footer: 'Didnt find a best place to store them?',
                pageIndex: 2,
                totalPages: 3,
                onNext:
                    _completeOnboarding, // Complete onboarding on final page
              ),
            ],
          ),
          // Dots at the bottom for navigation
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2, // Total number of onboarding screens
                (index) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: _currentIndex == index
                          ? Colors.blue
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String logo;
  final String banner;
  final String mainImage;
  final String title;
  final String subtitle;
  final String description;
  final String footer;
  final int pageIndex;
  final int totalPages;
  final VoidCallback onNext;

  const OnboardingPage({
    required this.logo,
    required this.banner,
    required this.mainImage,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.footer,
    required this.pageIndex,
    required this.totalPages,
    required this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE2EBF2), // 75% gradient
                  Color(0xFF83888C), // 100% gradient
                ],
                stops: [0.75, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Onboarding Image (Banner)
        Positioned.fill(
          child: Image.asset(
            banner,
            fit: BoxFit.fill,
          ),
        ),
        // Content on top of the background image
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              // Logo
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(10.0), // Curved border added
                child: Image.asset(
                  'assets/icons/LogoFill.png',
                  height: 80,
                  fit: BoxFit.cover, // Ensure proper scaling inside the border
                ),
              ),
              const SizedBox(height: 20),
              // Title
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
                  title,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rufina',
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Horizontal Line
              Container(
                width: 250,
                height: 2,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Rufina',
                ),
              ),
              const SizedBox(height: 60),
              // Main Image
              Center(
                child: Image.asset(mainImage, height: 250),
              ),
            ],
          ),
        ),
        // Description and Footer
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.13,
          left: 15,
          right: 15,
          child: Column(
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Times New Roman',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                footer,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(167, 0, 0, 0),
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Mulish',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Next Button
        Positioned(
          bottom: 20,
          right: 20,
          child: TextButton(
            onPressed: onNext,
            child: const Text(
              'Next >',
              style: TextStyle(
                color: Color.fromARGB(255, 21, 13, 189),
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
