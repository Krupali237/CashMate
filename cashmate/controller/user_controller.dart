import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../import_export.dart' hide DBHelper;
import '../income_expence/db_helper_deshboard.dart';
import '../model/user_model_deshbord.dart';

class UserController extends GetxController {
  Rxn<UserModel> currentUser = Rxn<UserModel>();
  var isEditingName = false.obs;
  var nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  /// 🔹 Load Current User
  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('signedUpEmail');

    if (userEmail != null) {
      final allUsers = await DBHelper.getUsers();
      final matchedUser =
      allUsers.firstWhereOrNull((user) => user.email == userEmail);
      if (matchedUser != null) {
        currentUser.value = matchedUser;
      }
    }
  }

  /// 🔹 Update User Name (DB + Local State + SharedPreferences)
  Future<void> updateUserName(String newName) async {
    if (currentUser.value != null) {
      // Update local object
      final updatedUser = currentUser.value!.copyWith(name: newName);
      currentUser.value = updatedUser;

      // Update DB
      await DBHelper.updateUser(updatedUser);

      // Optional: save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("username_${updatedUser.email}", newName);
    }
  }


  /// 🔹 Delete Current User
  Future<void> deleteCurrentUser() async {
    if (currentUser.value != null) {
      await DBHelper.deleteUser(currentUser.value!.id!);
      currentUser.value = null;
    }
  }

  /// 🔹 Refresh User Info (when profile changes)
  Future<void> refreshUser() async {
    await loadCurrentUser();
  }
}
