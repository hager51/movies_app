import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    goToNextScreen();
  }

  void goToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset('assets/Logos/movies_logo.png', width: 150),
              ),
            ),
            buildBottomLogo(),
          ],
        ),
      ),
    );
  }

  Widget buildBottomLogo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Image.asset('assets/Logos/route_logo.png', width: 80),
          const SizedBox(height: 8),
          const Text(
            'Supervised by Mohamed Nabil',
            style: TextStyle(color: AppColors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}