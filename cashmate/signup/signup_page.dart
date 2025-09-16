
import 'package:app/import_export.dart';


class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final AuthController authController = Get.put(AuthController());

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySignedUp();
  }

  // ✅ Check if user already signed up before
  Future<void> _checkIfAlreadySignedUp() async {
    final prefs = await SharedPreferences.getInstance();
    final isSignedUp = prefs.getBool('isSignedUp') ?? false;

    // if (isSignedUp) {
    //   await Future.delayed(const Duration(milliseconds: 1000));
    //   Get.snackbar("Welcome Back", "Redirecting to Login...",
    //       snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.black12);
    //   await Future.delayed(const Duration(milliseconds: 1500));
    //   //Get.offNamed('/LoginView'); // 🔁 Navigate to Login page
    // }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xC884D5E3), Color(0xFFFFFFFF)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xC884D5E3), Color(0xFFFFFFFF)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30),
                            Text(
                              "Create Account",
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildTextField(
                                    icon: Iconsax.user,
                                    hint: "Full Name",
                                    controller: authController.nameController,
                                    keyboardType: TextInputType.name,
                                  ),
                                  const SizedBox(height: 18),
                                  _buildTextField(
                                    icon: Iconsax.direct,
                                    hint: "Email",
                                    controller: authController.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 18),
                                  _buildTextField(
                                    icon: Iconsax.lock,
                                    hint: "Password",
                                    controller: authController.passwordController,
                                    isPassword: true,
                                    isHidden: hidePassword,
                                    toggleVisibility: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  _buildTextField(
                                    icon: Iconsax.lock_1,
                                    hint: "Confirm Password",
                                    controller: authController.confirmPasswordController,
                                    isPassword: true,
                                    isHidden: hideConfirmPassword,
                                    toggleVisibility: () {
                                      setState(() {
                                        hideConfirmPassword = !hideConfirmPassword;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 28),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => authController.signUpUser(),
                                      //onPressed: () => _signUpUser(),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        backgroundColor: const Color(0xFF333333),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        textStyle: GoogleFonts.poppins(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      child: const Text("Sign Up"),
                                    ),
                                  ),


                                  SizedBox(height: 16),

                                  // ElevatedButton.icon(
                                  //   onPressed: () => authController.signInWithGoogle(),
                                  //   icon: Icon(Icons.g_mobiledata),
                                  //   label: Text("Sign in with Google"),
                                  // ),

                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                            // TextButton(
                            //   onPressed: () => Get.offNamed('/LoginView'),
                            //   child: Text(
                            //     "Already have an account? Login",
                            //     style: GoogleFonts.poppins(
                            //       color: Colors.black87,
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            // ),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                children: [
                                  const TextSpan(text: "Already have an account? "),
                                  TextSpan(
                                    text: 'Login',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Get.toNamed('/LoginView'); // Make sure this route is defined
                                      },
                                  ),
                                ],
                              ),
                            ),
                             SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signUpUser() async {
    final name = authController.nameController.text.trim();
    final email = authController.emailController.text.trim();
    final password = authController.passwordController.text.trim();
    final confirmPassword = authController.confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('signedUpName', name);
    await prefs.setString('signedUpEmail', email);
    await prefs.setString('signedUpPassword', password);
    await prefs.setBool('isSignedUp', true);
    await prefs.setBool('isLoggedIn', true);

    Get.offAllNamed('/DashboardView');
  }


  // Future<void> googleSignIn() async {
  //   final googleUser = await GoogleSignInService.signInWithGoogle();
  //   if (googleUser != null) {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString("user_email", googleUser.email);
  //     await prefs.setString("user_name", googleUser.displayName ?? "Guest");
  //
  //     Get.offAll(() => DashboardView());
  //   } else {
  //     Get.snackbar("Google Sign-In", "Sign-In Failed");
  //   }
  // }


  Widget _buildTextField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isHidden = false,
    VoidCallback? toggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && isHidden,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              isHidden ? Icons.visibility_off : Icons.visibility,
              color: Colors.black,
            ),
            onPressed: toggleVisibility,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
  }
}
