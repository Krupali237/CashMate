import 'package:get/get.dart';

import 'package:app/import_export.dart';
class SettingsController extends GetxController {
  final box = GetStorage();

  // Reactive variables
  RxBool isDarkMode = false.obs;
  RxBool isSoundOn = true.obs;
  RxBool isNotificationEnabled = true.obs;
  RxString reminderTime = "Daily at 8:00 AM".obs;
  RxString budgetCycle = "Start every month on 1st".obs;

  @override
  void onInit() {
    GetStorage.init(); // ✅ not awaited = okay here
    _loadSettings();
    super.onInit();
  }


  void _loadSettings() {
    isDarkMode.value = box.read('isDarkMode') ?? false;
    isSoundOn.value = box.read('isSoundOn') ?? true;
    isNotificationEnabled.value = box.read('isNotificationEnabled') ?? true;
    reminderTime.value = box.read('reminderTime') ?? "Daily at 8:00 AM";
    budgetCycle.value = box.read('budgetCycle') ?? "Start every month on 1st";

    _applyTheme(); // Apply dark mode to app
  }

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    box.write('isDarkMode', isDarkMode.value);
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleSound() {
    isSoundOn.value = !isSoundOn.value;
    box.write('isSoundOn', isSoundOn.value);
  }

  void toggleNotifications() {
    isNotificationEnabled.value = !isNotificationEnabled.value;
    box.write('isNotificationEnabled', isNotificationEnabled.value);
  }

  void setReminderTime(String time) {
    reminderTime.value = time;
    box.write('reminderTime', time);
  }

  void setBudgetCycle(String cycle) {
    budgetCycle.value = cycle;
    box.write('budgetCycle', cycle);
  }
}
