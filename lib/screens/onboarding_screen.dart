import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final int pageIndex;

  const OnboardingScreen({super.key, this.pageIndex = 0});

  static const List<Map<String, String>> pages = [
    {
      'image': 'assets/images/onboarding_1.png',
      'title': 'Find Your Next\nFavorite Movie Here',
      'description':
      'Get access to a huge library of movies to suit all tastes. You will surely like it.',
      'button': 'Explore Now',
    },
    {
      'image': 'assets/images/onboarding_2.png',
      'title': 'Discover Movies',
      'description':
      'Explore a vast collection of movies in all qualities and genres. Find your next favorite film with ease.',
      'button': 'Next',
    },
    {
      'image': 'assets/images/onboarding_3.png',
      'title': 'Explore All Genres',
      'description':
      'Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.',
      'button': 'Next',
    },
    {
      'image': 'assets/images/onboarding_4.png',
      'title': 'Create Watchlists',
      'description':
      'Save movies to your watchlist to keep track of what you want to watch next. Enjoy films in various qualities and genres.',
      'button': 'Next',
    },
    {
      'image': 'assets/images/onboarding_5.png',
      'title': 'Rate, Review, and Learn',
      'description':
      'Share your thoughts on the movies you\'ve watched. Dive deep into film details and help others discover great movies with your reviews.',
      'button': 'Next',
    },
    {
      'image': 'assets/images/onboarding_6.png',
      'title': 'Start Watching Now',
      'description': '',
      'button': 'Finish',
    },
  ];

  bool get isFirstPage => pageIndex == 0;
  bool get isLastPage => pageIndex == pages.length - 1;

  @override
  Widget build(BuildContext context) {
    final page = pages[pageIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          buildBackgroundImage(context, page['image']!),
          isFirstPage
              ? buildFirstPageContent(context, page)
              : buildBottomCard(context, page),
        ],
      ),
    );
  }

  Widget buildBackgroundImage(BuildContext context, String imagePath) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = isFirstPage ? screenHeight : screenHeight * 0.726;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: imageHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppColors.card);
              },
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.6, 1.0],
                  colors: [Colors.transparent, AppColors.background],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFirstPageContent(BuildContext context, Map<String, String> page) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, AppColors.background],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              page['title']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              page['description']!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            buildYellowButton(context, page['button']!),
          ],
        ),
      ),
    );
  }

  Widget buildBottomCard(BuildContext context, Map<String, String> page) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        constraints: BoxConstraints(minHeight: screenHeight * 0.366),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF121312),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              page['title']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (page['description']!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                page['description']!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grey, fontSize: 16),
              ),
            ],
            const SizedBox(height: 20),
            buildYellowButton(context, page['button']!),
            const SizedBox(height: 12),
            buildBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget buildYellowButton(BuildContext context, String text) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => goNext(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.background,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => goBack(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.yellow, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Back',
          style: TextStyle(
            color: AppColors.yellow,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void goNext(BuildContext context) {
    if (isLastPage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(pageIndex: pageIndex + 1),
        ),
      );
    }
  }

  void goBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(pageIndex: pageIndex - 1),
      ),
    );
  }
}