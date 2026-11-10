import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final AuthService authService = AuthService();

  int selectedAvatar = 0;
  bool hidePassword = true;
  bool hideConfirm = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String? validateFields() {
    if (nameController.text.trim().isEmpty) return 'Please enter your name';
    if (!emailController.text.contains('@')) return 'Please enter a valid email';
    if (passwordController.text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (passwordController.text != confirmController.text) {
      return 'Passwords do not match';
    }
    if (phoneController.text.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    return null;
  }

  Future<void> onCreateAccountPressed() async {
    final validationError = validateFields();
    if (validationError != null) {
      showMessage(validationError);
      return;
    }

    setState(() => isLoading = true);
    final error = await authService.register(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      phone: phoneController.text,
      avatarIndex: selectedAvatar,
    );
    if (!mounted) return;
    setState(() => isLoading = false);

    if (error != null) {
      showMessage(error);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
      );
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
              const SizedBox(height: 10),
              buildAvatarPicker(),
              const SizedBox(height: 4),
              const Text('Avatar', style: TextStyle(color: AppColors.white)),
              const SizedBox(height: 20),
              buildTextField(
                controller: nameController,
                hint: 'Name',
                iconPath: 'assets/Icons/Identification_icon.png',
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: emailController,
                hint: 'Email',
                iconPath: 'assets/Icons/Email_icon.png',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              buildPasswordField(
                controller: passwordController,
                hint: 'Password',
                isHidden: hidePassword,
                onToggle: () => setState(() => hidePassword = !hidePassword),
              ),
              const SizedBox(height: 16),
              buildPasswordField(
                controller: confirmController,
                hint: 'Confirm Password',
                isHidden: hideConfirm,
                onToggle: () => setState(() => hideConfirm = !hideConfirm),
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: phoneController,
                hint: 'Phone Number',
                iconPath: 'assets/Icons/Phone_icon.png',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              buildCreateButton(),
              const SizedBox(height: 16),
              buildLoginRow(),
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
        'Register',
        style: TextStyle(color: AppColors.yellow, fontSize: 16),
      ),
    );
  }

  Widget buildAvatarPicker() {
    return SizedBox(
      height: 130,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(9, (index) => buildAvatarItem(index)),
        ),
      ),
    );
  }

  Widget buildAvatarItem(int index) {
    final isSelected = index == selectedAvatar;
    final size = isSelected ? 120.0 : 80.0;

    return GestureDetector(
      onTap: () => setState(() => selectedAvatar = index),
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.card,
          border: isSelected
              ? Border.all(color: AppColors.yellow, width: 3)
              : null,
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

  InputDecoration buildDecoration({
    required String hint,
    required String iconPath,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.white),
      filled: true,
      fillColor: AppColors.card,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(14),
        child: Image.asset(iconPath, width: 22),
      ),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required String iconPath,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white),
      decoration: buildDecoration(hint: hint, iconPath: iconPath),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isHidden,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isHidden,
      style: const TextStyle(color: AppColors.white),
      decoration: buildDecoration(
        hint: hint,
        iconPath: 'assets/Icons/Password_icon.png',
        suffix: IconButton(
          onPressed: onToggle,
          icon: Image.asset('assets/Icons/eye_icon.png', width: 22),
        ),
      ),
    );
  }

  Widget buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onCreateAccountPressed,
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
          'Create Account',
          style: TextStyle(
            color: AppColors.background,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already Have Account ? ',
          style: TextStyle(color: AppColors.white),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: const Text(
            'Login',
            style: TextStyle(
              color: AppColors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}