import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/auth_service.dart';
import '../services/user_movies_service.dart';
import '../utils/app_colors.dart';
import '../widgets/movie_card.dart';
import 'login_screen.dart';
import 'update_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserMoviesService service = UserMoviesService();

  int selectedTab = 0;

  Future<void> onExitPressed() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<MovieModel>>(
        stream: service.watchlistStream(),
        builder: (context, watchSnapshot) {
          return StreamBuilder<List<MovieModel>>(
            stream: service.historyStream(),
            builder: (context, historySnapshot) {
              final watchlist = watchSnapshot.data ?? [];
              final history = historySnapshot.data ?? [];
              final currentList = selectedTab == 0 ? watchlist : history;

              return Column(
                children: [
                  buildHeader(watchlist.length, history.length),
                  buildTabs(),
                  Expanded(child: buildTabContent(currentList)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget buildHeader(int watchCount, int historyCount) {
    return Container(
      width: double.infinity,
      color: AppColors.card,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        children: [
          StreamBuilder<Map<String, dynamic>?>(
            stream: service.userStream(),
            builder: (context, snapshot) {
              final data = snapshot.data;
              final name = data?['name'] ?? '';
              final avatarIndex = data?['avatarIndex'] ?? 0;

              return Row(
                children: [
                  buildAvatarWithName(avatarIndex, name),
                  Expanded(child: buildCounter('$watchCount', 'Wish List')),
                  Expanded(child: buildCounter('$historyCount', 'History')),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          buildButtons(),
        ],
      ),
    );
  }

  Widget buildAvatarWithName(int avatarIndex, String name) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/avatars/avatar_${avatarIndex + 1}.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, color: AppColors.grey, size: 50);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildCounter(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildButtons() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdateProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onExitPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout, color: AppColors.white, size: 20),
              label: const Text(
                'Exit',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTabs() {
    return Container(
      color: AppColors.card,
      child: Row(
        children: [
          Expanded(
            child: buildTabItem(0, 'Watch List', 'assets/Icons/WatchList_icon.png'),
          ),
          Expanded(
            child: buildTabItem(1, 'History', 'assets/Icons/Folder.png'),
          ),
        ],
      ),
    );
  }

  Widget buildTabItem(int index, String title, String iconPath) {
    final isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.yellow : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Image.asset(iconPath, width: 26),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: AppColors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(List<MovieModel> movies) {
    if (movies.isEmpty) {
      return Center(
        child: Image.asset(
          'assets/images/empty_state.png',
          width: 120,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.movie_outlined,
              color: AppColors.yellow,
              size: 80,
            );
          },
        ),
      );
    }

    final cardWidth = (MediaQuery.of(context).size.width - 16 * 2 - 10 * 2) / 3;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: movies.map((movie) {
          return MovieCard(
            movie: movie,
            width: cardWidth,
            height: cardWidth * 1.5,
          );
        }).toList(),
      ),
    );
  }
}