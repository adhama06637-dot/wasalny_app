import 'package:flutter/material.dart';
import 'package:waslny/Onboarding.dart'; // ⚠️ اتأكد إن الـ Import ده لصفحة الـ Onboarding

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> opacity;
  late Animation<Offset> position;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    opacity = Tween<double>(begin: 0, end: 1).animate(controller);

    // أنيميشن الطلوع لفوق اللي إنت حبيته
    position = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack, // سوستة خفيفة في الآخر عشان الحركة تكون "لذيذة"
      ),
    );

    controller.forward();

    // 🚀 التعديل الجوهري هنا: التوجيه لصفحة الـ Onboarding 
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(), // هنا بننادي على الـ 3 مراحل
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // 🎨 كسر حدة اللون الأزرق بتدرج دائري (Radial Gradient)
          gradient: RadialGradient(
            colors: [
              Color(0xFF4A4ABF), // أزرق فاتح ومنور في النص
              Color(0xFF303099), // اللون الأزرق بتاعك الأساسي على الأطراف
            ],
            radius: 1.0,
          ),
        ),
        child: Stack(
          children: [
            // صورة الخلفية (لو حابب تسيبها زي ما كانت)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1, // تظليل خفيف جداً للصورة عشان متزحمش العين
                child: Image.asset(
                  "assets/images/splash waslny.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ),
            
            // النص المتحرك في السنتر
            Center(
              child: FadeTransition(
                opacity: opacity,
                child: SlideTransition(
                  position: position,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "WASALNY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontFamily: 'AbrilFatface',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // خط أبيض رفيع تحت الكلمة بيدي شكل مودرن
                      Container(
                        width: 100,
                        height: 2,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}