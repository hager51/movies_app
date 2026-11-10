import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final AuthService authService = AuthService();

  int selectedAvatar = 0;
  bool isLoadingData = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();

      if (!mounted) return;
      setState(() {
        nameController.text = data?['name'] ?? '';
        phoneController.text = data?['phone'] ?? '';
        selectedAvatar = data?['avatarIndex'] ?? 0;
        isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingData = false);
      showMessage('Could not load your data');
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> onUpdatePressed() async {
    if (nameController.text.trim().isEmpty) {
      showMessage('Please enter your name');
      return;
    }

    setState(() => isSaving = true);
    final error = await authService.updateProfile(
      name: nameController.text,
      phone: phoneController.text,
      avatarIndex: selectedAvatar,
    );
    if (!mounted) return;
    setState(() => isSaving = false);

    if (error != null) {
      showMessage(error);
    } else {
      showMessage('Data updated');
      Navigator.pop(context);
    }
  }

  Future<void> onResetPasswordPressed() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      showMessage('No email found for this account');
      return;
    }

    final error = await authService.resetPassword(email);
    if (!mounted) return;
    showMessage(error ?? 'Reset link sent, check your email');
  }

  Future<void> onDeletePressed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Delete Account',
            style: TextStyle(color: AppColors.white),
          ),
          content: const Text(
            'Your account and all your data will be deleted permanently.',
            style: TextStyle(color: AppColors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => isSaving = true);
    final error = await authService.deleteAccount();
    if (!mounted) return;
    setState(() => isSaving = false);

    if (error != null) {
      showMessage(error);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  void showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: List.generate(9, (index) => buildPickerItem(index)),
          ),
        );
      },
    );
  }

  Widget buildPickerItem(int index) {
    final isSelected = index == selectedAvatar;

    return GestureDetector(
      onTap: () {
        setState(() => selectedAvatar = index);
        Navigator.pop(context);
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.yellow.withOpacity(0.4)
              : AppColors.background,
          border: Border.all(color: AppColors.yellow, width: 1.5),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/avatars/avatar_${index + 1}.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, color: AppColors.grey);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(),
      body: SafeArea(
        child: isLoadingData
            ? const Center(
          child: CircularProgressIndicator(color: AppColors.yellow),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              buildAvatar(),
              const SizedBox(height: 30),
              buildTextField(
                controller: nameController,
                hint: 'Name',
                iconPath: 'assets/Icons/User-4.png',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: phoneController,
                hint: 'Phone Number',
                iconPath: 'assets/Icons/Phone_icon.png',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              buildResetPasswordLink(),
              const SizedBox(height: 60),
              buildDeleteButton(),
              const SizedBox(height: 14),
              buildUpdateButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Image.asset('assets/Icons/back_icon.png', width: 24),
      ),
      title: const Text(
        'Pick Avatar',
        style: TextStyle(color: AppColors.yellow, fontSize: 16),
      ),
    );
  }

  Widget buildAvatar() {
    return GestureDetector(
      onTap: showAvatarPicker,
      child: Container(
        width: 140,
        height: 140,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.card,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/avatars/avatar_${selectedAvatar + 1}.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, color: AppColors.grey, size: 60);
            },
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required String iconPath,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey),
        filled: true,
        fillColor: AppColors.card,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: Image.asset(iconPath, width: 22),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildResetPasswordLink() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onResetPasswordPressed,
        child: const Text(
          'Reset Password',
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSaving ? null : onDeletePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Delete Account',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSaving ? null : onUpdatePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isSaving
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.background,
            strokeWidth: 3,
          ),
        )
            : const Text(
          'Update Data',
          style: TextStyle(
            color: AppColors.background,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}