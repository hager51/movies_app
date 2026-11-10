import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'forget_password_screen.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> onLoginPressed() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showMessage('Please enter email and password');
      return;
    }

    setState(() => isLoading = true);
    final error = await authService.login(
      emailController.text,
      passwordController.text,
    );
    if (!mounted) return;
    setState(() => isLoading = false);

    if (error != null) {
      showMessage(error);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  Future<void> onGooglePressed() async {
    setState(() => isLoading = true);
    final error = await authService.loginWithGoogle();
    if (!mounted) return;
    setState(() => isLoading = false);

    if (error != null) {
      showMessage(error);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/Logos/movies_logo.png', width: 120),
              const SizedBox(height: 60),
              buildTextField(
                controller: emailController,
                hint: 'Email',
                iconPath: 'assets/Icons/Email_icon.png',
              ),
              const SizedBox(height: 20),
              buildTextField(
                controller: passwordController,
                hint: 'Password',
                iconPath: 'assets/Icons/Password_icon.png',
                isPassword: true,
              ),
              buildForgetPasswordLink(),
              const SizedBox(height: 10),
              buildLoginButton(),
              const SizedBox(height: 20),
              buildCreateAccountRow(),
              const SizedBox(height: 20),
              buildOrDivider(),
              const SizedBox(height: 20),
              buildGoogleButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required String iconPath,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && hidePassword,
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.white),
        filled: true,
        fillColor: AppColors.card,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: Image.asset(iconPath, width: 22),
        ),
        suffixIcon: isPassword
            ? IconButton(
          onPressed: () => setState(() => hidePassword = !hidePassword),
          icon: Image.asset('assets/Icons/eye_icon.png', width: 22),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildForgetPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgetPasswordScreen(),
            ),
          );
        },
        child: const Text(
          'Forget Password ?',
          style: TextStyle(color: AppColors.yellow, fontSize: 14),
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onLoginPressed,
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
          'Login',
          style: TextStyle(
            color: AppColors.background,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildCreateAccountRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't Have Account ? ",
          style: TextStyle(color: AppColors.white),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: const Text(
            'Create One',
            style: TextStyle(
              color: AppColors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOrDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.yellow)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(color: AppColors.yellow)),
        ),
        Expanded(child: Divider(color: AppColors.yellow)),
      ],
    );
  }

  Widget buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onGooglePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.background,
            strokeWidth: 3,
          ),
        )
            : Image.asset('assets/Icons/google_icon.png', width: 24),

        label: Text(
          isLoading ? 'Please wait...' : 'Login With Google',
          style: const TextStyle(
            color: AppColors.background,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}