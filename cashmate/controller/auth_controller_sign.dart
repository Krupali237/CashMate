import 'package:app/import_export.dart';

import '../signup/db_helper_sign.dart';
class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ✅ SIGN UP LOGIC
  Future<void> signUpUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Invalid Email", "Please enter a valid email");
      return;
    }

    if (password.length < 6) {
      Get.snackbar("Weak Password", "Password should be at least 6 characters");
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isSignedUp', true);
      await prefs.setString('signedUpEmail', email);
      await prefs.setString('signedUpPassword', password);
      await prefs.setBool('isLoggedIn', true);

      Get.offAllNamed('/DashboardView');
    } catch (e) {
      Get.snackbar("Error", "Something went wrong. Try again.");
    }
  }

  // ✅ CHANGE PASSWORD LOGIC
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();

    final savedPassword = prefs.getString('signedUpPassword');
    final savedEmail = prefs.getString('signedUpEmail');

    if (savedPassword == null || savedEmail == null) {
      Get.snackbar("Error", "User not found. Please log in again.");
      return false;
    }

    if (currentPassword != savedPassword) {
      return false;
    }

    await prefs.setString('signedUpPassword', newPassword);
    return true;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
