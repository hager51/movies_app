import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> onVerifyPressed() async {
    if (!emailController.text.contains('@')) {
      showMessage('Please enter a valid email');
      return;
    }

    setState(() => isLoading = true);
    final error = await authService.resetPassword(emailController.text);
    if (!mounted) return;
    setState(() => isLoading = false);

    if (error != null) {
      showMessage(error);
    } else {
      showMessage('Reset link sent, check your email');
      Navigator.pop(context);
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/forget_password.png',
                height: 280,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(height: 280);
                },
              ),
              const SizedBox(height: 30),
              buildEmailField(),
              const SizedBox(height: 20),
              buildVerifyButton(),
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
        'Forget Password',
        style: TextStyle(color: AppColors.yellow, fontSize: 16),
      ),
    );
  }

  Widget buildEmailField() {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: const TextStyle(color: AppColors.white),
        filled: true,
        fillColor: AppColors.card,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: Image.asset('assets/Icons/Email_icon.png', width: 22),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onVerifyPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.background,
            strokeWidth: 3,
          ),
        )
            : const Text(
          'Verify Email',
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