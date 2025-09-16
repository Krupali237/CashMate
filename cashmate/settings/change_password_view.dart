import 'package:app/import_export.dart';

class ChangePasswordView extends StatefulWidget {
  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final AuthController authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xC833A0B2), Color(0xFFCBBDBD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  "Change Password",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideY(begin: -0.3),

          const SizedBox(height: 30),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Card Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildPasswordField(
                            controller: currentPasswordController,
                            label: "Current Password",
                            icon: Iconsax.lock,
                            hide: _hideCurrent,
                            onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
                            validator: (val) => val == null || val.isEmpty
                                ? "Enter current password"
                                : null,
                          ),
                          const SizedBox(height: 20),

                          _buildPasswordField(
                            controller: newPasswordController,
                            label: "New Password",
                            icon: Iconsax.key,
                            hide: _hideNew,
                            onToggle: () => setState(() => _hideNew = !_hideNew),
                            validator: (val) =>
                            val != null && val.length >= 6
                                ? null
                                : "Password must be at least 6 characters",
                          ),
                          const SizedBox(height: 20),

                          _buildPasswordField(
                            controller: confirmPasswordController,
                            label: "Confirm Password",
                            icon: Iconsax.password_check,
                            hide: _hideConfirm,
                            onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
                            validator: (val) =>
                            val == newPasswordController.text
                                ? null
                                : "Passwords do not match",
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 600.ms).slideY(begin: 0.1),

                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.save,color: Colors.white,),
                      label: Text("Update Password", style: GoogleFonts.poppins(fontSize: 16,color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 5,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          bool success = await authController.changePassword(
                            currentPasswordController.text.trim(),
                            newPasswordController.text.trim(),
                          );

                          if (success) {
                            Get.snackbar("Success", "Password changed successfully. Please login again.",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green.shade50,
                                colorText: Colors.green.shade900);
                            Get.offAllNamed("/login");
                          } else {
                            Get.snackbar("Error", "Current password is incorrect.",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.shade50,
                                colorText: Colors.red.shade900);
                          }
                        }
                      },
                    ).animate().fade().slideY(begin: 0.2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool hide,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: hide,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      validator: validator,
    );
  }
}
