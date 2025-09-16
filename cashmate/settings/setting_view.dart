
import 'package:app/import_export.dart';




class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsController settingsController = Get.put(SettingsController());
  final ThemeController themeController = Get.find<ThemeController>();


  bool isDarkMode = false;
  bool isSoundOn = true;
  bool isNotificationEnabled = true;
  String appVersion = "1.0.0";
  String reminderTime = "Daily at 8:00 AM";
  String budgetCycle = "Start every month on 1st";

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
  }

  void _showReminderPicker() async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay(hour: 8, minute: 0);

    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: 60,
                height: 6,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Text(
                "Set Goal Reminder",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Date Picker Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Date:", style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: selectedDate,
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.deepPurple, // header
                                onPrimary: Colors.white, // text
                                surface: Colors.white, // background
                                onSurface: Colors.black, // text
                              ),
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                    child: Text(
                      "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                      style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Time Picker Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Time:", style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.deepPurple,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) setState(() => selectedTime = time);
                    },
                    child: Text(
                      selectedTime.format(context),
                      style: const TextStyle(fontSize: 16, color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Set Reminder Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final formattedReminder =
                        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} at ${selectedTime.format(context)}";

                    settingsController.setReminderTime(formattedReminder);
                    Get.back();
                    Get.snackbar("Reminder Set", "Goal reminder set for $formattedReminder",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade400,
                        colorText: Colors.white);
                  },
                  child: const Text(
                    "Set Reminder",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }



  void _selectBudgetCycle() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Start every month on 1st"),
              onTap: () {
                settingsController.setBudgetCycle("Start every month on 1st");
                Get.back();
              },
            ),
            ListTile(
              title: Text("Start every month on 15th"),
              onTap: () {
                settingsController.setBudgetCycle("Start every month on 15th");
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }






  void exportDataAsPdf() async {
    final transactionController = Get.find<TransactionController>();
    final allTransactions = transactionController.transactions.toList();

    if (allTransactions.isEmpty) {
      Get.snackbar("No Data", "There are no transactions to export.");
      return;
    }

    try {
      final file = await PDFExporter.generatePdf(allTransactions);

      // ✅ Custom Professional Dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon with Circle Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.cyan.shade800,
                  child: const Icon(Icons.picture_as_pdf, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "PDF Created!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                // const Text(
                //   "Your dashboard and transaction report has been saved successfully.",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 16,
                //     color: Colors.black54,
                //   ),
                // ),
                // const SizedBox(height: 25),
                //
                // // File Path Info (Optional)
                // // Text(
                // //   "Saved at:\n${file.path}",
                // //   textAlign: TextAlign.center,
                // //   style: const TextStyle(
                // //     fontSize: 14,
                // //     color: Colors.black45,
                // //   ),
                // // ),
                // const SizedBox(height: 20),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.cyan.shade800,
                          side: const BorderSide(color: Colors.cyan),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text(
                          "Close",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Share Button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Get.back();
                          await Share.shareXFiles(
                            [XFile(file.path)],
                            text: "Here is my CashMate report 📑",
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text(
                          "Share",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to export PDF: $e");
    }
  }

  // void exportDataAsExcel() async {
  //   final activityController = Get.find<ActivityController>();
  //   final allActivities = activityController.allActivities;
  //
  //   if (allActivities.isEmpty) {
  //     Get.snackbar("No Data", "There are no transactions to export.");
  //     return;
  //   }
  //
  //   try {
  //     final file = await ExcelExporter.generateExcel(allActivities);
  //
  //     Get.defaultDialog(
  //       title: "Excel Exported",
  //       middleText: "Saved as ${file.path.split('/').last}",
  //       textConfirm: "Open",
  //       textCancel: "Cancel",
  //       confirmTextColor: Colors.white,
  //       onConfirm: () async {
  //         Get.back();
  //         await ExcelExporter.openExcel(file);
  //       },
  //       onCancel: () {
  //         Get.back();
  //       },
  //     );
  //   } catch (e) {
  //     Get.snackbar("Error", "Failed to export Excel: $e");
  //   }
  // }







  // void _contactSupport() {
  //   Get.to(() => ContactSupportScreen());
  // }



  void _sendFeedback() {
    Share.share("Hi SaveMate, I have some feedback...");
  }

  void _aboutApp() {
    Get.defaultDialog(
      title: "About SaveMate",
      content: Text("SaveMate helps you manage your expenses smartly."),
    );
  }

  void _editProfile() {
    Get.snackbar("Profile", "Edit Profile screen coming soon.");
  }

  void _changePassword() {
    Get.to(() => ChangePasswordView());
  }

  void _setExpenseReminder() {
    Get.snackbar("Reminder", "Expense reminder config coming soon.");
  }

  void _toggleNotifications(bool val) {
    setState(() => isNotificationEnabled = val);
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.cyan.shade800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Settings", style: GoogleFonts.poppins(fontWeight: FontWeight.w600,color: Colors.white)),
        backgroundColor: Colors.cyan.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // === ACCOUNT ===
          buildSectionTitle("Account"),
          // ListTile(
          //   leading: Icon(Icons.person_outline),
          //   title: Text("Edit Profile", style: GoogleFonts.poppins()),
          //   onTap: _editProfile,
          // ),
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text("Change Password", style: GoogleFonts.poppins()),
            onTap: _changePassword,
          ),

          // === BUDGET ===
          //buildSectionTitle("Budget"),
          // Obx(() => ListTile(
          //   leading: Icon(Icons.date_range),
          //   title: Text("Budget Cycle", style: GoogleFonts.poppins()),
          //   subtitle: Text(settingsController.budgetCycle.value, style: GoogleFonts.poppins(fontSize: 12)),
          //   onTap: _selectBudgetCycle,
          // )),

          // === PREFERENCES ===
          buildSectionTitle("Preferences"),
          Obx(() => SwitchListTile(
            title: Text('Dark Mode'),
            value: Get.find<ThemeController>().isDarkMode.value,
            onChanged: (value) => Get.find<ThemeController>().toggleTheme(value),
            secondary: Icon(Icons.dark_mode),
          )),

          // In the Preferences section of SettingsView
          // Obx(() => SwitchListTile(
          //   title: Text("Sound Effects", style: GoogleFonts.poppins(fontSize: 16)),
          //   value: settingsController.isSoundOn.value,
          //   onChanged: (val) => settingsController.toggleSound(),
          //   secondary: Icon(
          //     settingsController.isSoundOn.value ? Icons.volume_up : Icons.volume_off,
          //     color: Colors.cyan.shade800,
          //   ),
          //   activeColor: Colors.cyan.shade800,
          //   contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          // )),


          // === REMINDERS ===
          buildSectionTitle("Reminders & Notifications"),
          Obx(() => ListTile(
            leading: Icon(Icons.alarm),
            title: Text("Goal Reminder", style: GoogleFonts.poppins()),
            subtitle: Text(settingsController.reminderTime.value, style: GoogleFonts.poppins(fontSize: 12)),
            onTap: _showReminderPicker,
          )),


          // ListTile(
          //   leading: Icon(Icons.notifications_active),
          //   title: Text("Bill/Expense Reminder", style: GoogleFonts.poppins()),
          //   onTap: _setExpenseReminder,
          // ),
          // Obx(() => SwitchListTile(
          //   title: Text("Enable Notifications", style: GoogleFonts.poppins()),
          //   value: settingsController.isNotificationEnabled.value,
          //   onChanged: (_) => settingsController.toggleNotifications(),
          //   secondary: Icon(Icons.notifications),
          // )),
          // ListTile(
          //   leading: Icon(Icons.music_note_outlined),
          //   title: Text("Notification Tone", style: GoogleFonts.poppins()),
          //   subtitle: Text("Default", style: GoogleFonts.poppins(fontSize: 12)),
          //   onTap: () {
          //     Get.snackbar("Tone", "Custom tone picker coming soon");
          //   },
          // ),

          // === DATA EXPORT ===
          buildSectionTitle("Export Data"),
          ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text("Export as PDF", style: GoogleFonts.poppins()),
            onTap: exportDataAsPdf,   // ✅ ab yeh call karega
          ),

          // ListTile(
          //   leading: Icon(Icons.table_chart),
          //   title: Text("Export as Excel", style: GoogleFonts.poppins()),
          //   //onTap: exportDataAsExcel,
          // ),
            


          // === SECURITY ===
          // buildSectionTitle("Security"),
          // ListTile(
          //   leading: Icon(Icons.fingerprint),
          //   title: Text("App Lock", style: GoogleFonts.poppins()),
          //   trailing: Icon(Iconsax.toggle_on),
          //   onTap: () {
          //     Get.snackbar("Lock", "App Lock will be added soon");
          //   },
          // ),

          // === SUPPORT ===
          // buildSectionTitle("Support"),
          // ListTile(
          //   leading: Icon(Icons.support_agent),
          //   title: Text("Contact Support", style: GoogleFonts.poppins()),
          //   onTap: _contactSupport,
          // ),
          // ListTile(
          //   leading: Icon(Icons.feedback_outlined),
          //   title: Text("Send Feedback", style: GoogleFonts.poppins()),
          //   onTap: _sendFeedback,
          // ),

          // === ABOUT ===
          // buildSectionTitle("About"),
          // ListTile(
          //   leading: Icon(Icons.info_outline),
          //   title: Text("App Version", style: GoogleFonts.poppins()),
          //   trailing: Text(appVersion, style: GoogleFonts.poppins()),
          // ),
          // ListTile(
          //
          //   leading: Icon(Icons.logout),
          //   title: Text("Log Out", style: GoogleFonts.poppins(color: Colors.red)),
          //   onTap: () {
          //     // TODO: Implement logout logic
          //     Get.offAllNamed("/login");
          //   },
          // ),

          SizedBox(height: 24),
        ],
      ),
    );
  }
}
