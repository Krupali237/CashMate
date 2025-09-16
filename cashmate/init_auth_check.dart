
import 'package:app/import_export.dart';

class InitAuthCheck extends StatelessWidget {
  const InitAuthCheck({super.key});

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // ⏳ Wait a bit to show splash
    await Future.delayed(const Duration(seconds: 2));

    if (isLoggedIn) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    checkLoginStatus(); // ✅ Start checking immediately

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Optional Splash UI
      ),
    );
  }
}
