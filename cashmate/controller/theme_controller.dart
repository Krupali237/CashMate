
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // Reactive value to track dark mode
  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _loadThemeFromBox();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  void _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    _saveThemeToBox(value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}
