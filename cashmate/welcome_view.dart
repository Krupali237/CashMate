import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:app/import_export.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> with TickerProviderStateMixin {
  late AnimationController _coinController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    // === Coin animation ===
    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, -2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _coinController, curve: Curves.bounceOut));

    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _coinController, curve: Curves.elasticOut));

    _coinController.forward();
    _playCoinSound();

    // Unified delayed redirect after splash
    Future.delayed(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final onboardingSeen = prefs.getBool("onboarding_complete") ?? false;
      final isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

      if (!onboardingSeen) {
        Get.offAllNamed('/OnboardingView');
      } else if (!isLoggedIn) {
        Get.offAllNamed('/LoginView');
      } else {
        Get.offAllNamed('/DashboardView');
      }
    });
  }

  Future<void> _playCoinSound() async {
    // ✅ Make sure you added assets/sounds/drop-coin-384921.mp3 in pubspec.yaml
    await _audioPlayer.play(AssetSource('sounds/drop-coin-384921.mp3'));
  }

  @override
  void dispose() {
    _coinController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌊 Layered Wavy Background
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: UniqueCurvedBackgroundPainter(),
          ),

          // 🌟 Center Coin + Text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔆 Falling Coin Only
                SlideTransition(
                  position: _slideAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.orangeAccent, Colors.amber],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "₹",
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🧠 App Name & Tagline - static
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.white, Colors.cyanAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "CashMate",
                    style: GoogleFonts.montserrat(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black45,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Smart Budget. Easy Life.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UniqueCurvedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF333333), Color(0xFF777777)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), background);

    final paint1 = Paint()..color = const Color(0xFF005AA7).withOpacity(0.2);
    final path1 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 1.2, 0)
      ..lineTo(size.width, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.2, size.width * 0.5, 0)
      ..close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()..color = const Color(0xFF2BC0E4).withOpacity(0.3);
    final path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.9, size.width * 0.6, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.8, size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);

    final paint3 = Paint()..color = const Color(0xFFffffff).withOpacity(0.05);
    final path3 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.3)
      ..cubicTo(size.width * 0.2, size.height * 0.2, size.width * 0.4, size.height * 0.4,
          size.width * 0.6, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.2, size.width * 0.8, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.7, size.width * 0.3, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.05, size.height * 0.5, size.width * 0.1, size.height * 0.3)
      ..close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
