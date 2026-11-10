import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'browse_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  late final List<Widget> screens = [
    HomeScreen(onSeeMorePressed: () => changeTab(2)),
    const SearchScreen(),
    const BrowseScreen(),
    const ProfileScreen(),
  ];

  void changeTab(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget buildBottomBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildBarItem(0, 'assets/Icons/Home_icon.png'),
            buildBarItem(1, 'assets/Icons/Search_icon.png'),
            buildBarItem(2, 'assets/Icons/explore_icon.png'),
            buildBarItem(3, 'assets/Icons/Profiel_icon.png'),
          ],
        ),
      ),
    );
  }

  Widget buildBarItem(int index, String iconPath) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => changeTab(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.6,
          child: Image.asset(iconPath, width: 22),
        ),
      ),
    );
  }
}