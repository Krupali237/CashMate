
import 'package:app/import_export.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  Future<RouteSettings?> redirectFuture(String? route) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      return const RouteSettings(name: '/DashboardView');
    } else {
      return const RouteSettings(name: '/LoginView');
    }
  }
}
