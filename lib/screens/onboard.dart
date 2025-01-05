import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fuilio_app/screens/login_screen.dart';
import 'package:logger/logger.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Logger _logger = Logger();

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    _logger.d('hasSeenOnboarding set to true');
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const LoginSignup()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
              OnboardingPage(
                logo: 'assets/icons/LogoFill.png',
                banner: 'assets/images/onboard_placeholder.png',
                mainImage: 'assets/images/img_onboard1.png',
                title: 'FuiLio',
                subtitle: 'We value your money, even if it’s your vehicle',
                description: 'Do you really worry about\nyour savings!',
                footer: 'Couldn’t find a safe place to track\n your expenses?',
                pageIndex: 0,
                totalPages: 2,
                onNext: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              OnboardingPage(
                logo: 'assets/icons/LogoFill.png',
                banner: 'assets/images/onboard_placeholder.png',
                mainImage: 'assets/images/img_onboard2.png',
                title: 'FuiLio',
                subtitle: 'We got your expense covered',
                description: 'Trouble keep tracking\nyour records?',
                footer: 'Didn’t find a better place to store them?',
                pageIndex: 1,
                totalPages: 2,
                onNext: _completeOnboarding,
              ),
            ],
          ),
          Positioned(
            bottom: screenSize.height * 0.05,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                (index) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: _currentIndex == index ? 16 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
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
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE2EBF2), Color(0xFF83888C)],
                stops: [0.75, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Image.asset(
            banner,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.height * 0.1),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  logo,
                  height: screenSize.height * 0.08,
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF5B57CC), Color(0xFFDA5037)],
                ).createShader(bounds),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.001),
              Container(
                width: 280,
                height: 2,
                color: Colors.black,
              ),
              SizedBox(
                height: screenSize.height * 0.02,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: screenSize.width * 0.045,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenSize.height * 0.05),
              Center(
                child: Image.asset(
                  mainImage,
                  height: screenSize.height * 0.3,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: screenSize.height * 0.1,
          left: screenSize.width * 0.05,
          right: screenSize.width * 0.05,
          child: Column(
            children: [
              Text(
                description,
                style: TextStyle(
                  fontSize: screenSize.width * 0.045,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Mulish',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.02),
              Text(
                footer,
                style: TextStyle(
                  fontSize: screenSize.width * 0.04,
                  color: const Color.fromARGB(255, 105, 88, 88),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: screenSize.height * 0.03,
          right: screenSize.width * 0.05,
          child: TextButton(
            onPressed: onNext,
            child: const Text(
              'Next >',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 15,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
