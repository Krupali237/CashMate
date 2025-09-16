
import 'package:app/import_export.dart';

class DashboardController extends GetxController {
  var userName = ''.obs;
  var userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('signedUpName') ?? 'User';
    userEmail.value = prefs.getString('signedUpEmail') ?? 'email@example.com';
  }

  // ✅ LOGOUT Function (KEEP email/password saved)
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // only mark user as logged out

    Get.snackbar("Logged Out", "You have been logged out.",
        snackPosition: SnackPosition.BOTTOM);

    await Future.delayed(const Duration(seconds: 1));
    Get.offAllNamed('/LoginView'); // Redirect to login
  }

  // ❌ Delete ALL data (only use if user deletes account)
  Future<void> deleteAccountAndLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This clears email/password too

    Get.snackbar("Account Deleted", "All user data removed.",
        snackPosition: SnackPosition.BOTTOM);
    await Future.delayed(const Duration(seconds: 1));
    Get.offAllNamed('/signup'); // Redirect to SignUp
  }
}
