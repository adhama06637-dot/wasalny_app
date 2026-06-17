import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Login_Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}


// ================= ONBOARDING =================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Lost in\ntransportation?",
      subtitle: "Not sure what to take\nor where to go?",
      imagePath: 'assets/images/lost.svg',
    ),
    OnboardingData(
      title: "We guide you\nstep by step",
      subtitle: "Enter your trip and we'll show you\nexactly what to take.",
      imagePath: 'assets/images/waslny.png',
    ),
    OnboardingData(
      title: "Share your ride",
      subtitle: "Find or offer rides and travel\ntogether.",
      imagePath: 'assets/images/Carpool.svg',
    ),
  ];

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // SKIP
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: goToLogin,
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Color(0xFF4A4ED7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // PAGES
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingContent(data: _pages[index]);
                },
              ),
            ),

            // DOTS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => buildDot(index),
              ),
            ),

            const SizedBox(height: 32),

            // BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4ED7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      goToLogin();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? "Let's start"
                        : "Next",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      height: 8,
      width: 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF4A4ED7)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ================= CONTENT =================
class OnboardingContent extends StatelessWidget {
  final OnboardingData data;

  const OnboardingContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
          flex: 3,
          child: data.imagePath.endsWith('.svg')
                 ? SvgPicture.asset(
                 data.imagePath,
                 fit: BoxFit.contain,
                 )
                  : Image.asset(
                    data.imagePath,
                   fit: BoxFit.contain,
                    ),
               ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ================= MODEL =================
class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}