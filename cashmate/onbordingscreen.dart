
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app/import_export.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}



class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  bool onLastPage = false;


  final List<Map<String, dynamic>> onboardingData = [
    {
      "icon": Iconsax.wallet_3,
      "title": "Track Every Rupee",
      "desc": "Keep an eye on your expenses & savings with ease.",
    },
    {
      "icon": Iconsax.chart,
      "title": "Visualize Your Budget",
      "desc": "Interactive graphs to manage income & spending smartly.",
    },
    {
      "icon": Iconsax.security,
      "title": "Safe & Secure",
      "desc": "Your financial data is protected with top-notch security.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;


    return Scaffold(
      backgroundColor: const Color(0xFFf1f4ff),
      body: Stack(
        children: [
          // Curved background
          Positioned(
            top: -size.height * 0.15,
            left: -size.width * 0.3,
            child: Container(
              height: size.height * 0.5,
              width: size.width * 1.2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF333333), Color(0xFF777777)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(300),
                  bottomLeft: Radius.circular(300),
                ),
              ),
            ).animate().fade(duration: 1200.ms),
          ),

          // Main Content
          Column(
            children: [
              const SizedBox(height: 120),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() => onLastPage = index == onboardingData.length - 1);
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (_, index) {
                    var data = onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          Icon(
                            data['icon'],
                            size: 120,
                            color: Colors.cyanAccent,
                          ).animate().slideY(duration: 800.ms),

                          const SizedBox(height: 60),
                          Text(
                            data['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ).animate().fade(duration: 800.ms),

                          const SizedBox(height: 15),
                          Text(
                            data['desc'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ).animate().fade(duration: 900.ms),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page Indicator
              SmoothPageIndicator(
                controller: _controller,
                count: onboardingData.length,
                effect:  WormEffect(
                  activeDotColor: Colors.cyanAccent,
                  dotColor: Colors.grey,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),

              const SizedBox(height: 30),

              // Bottom Buttons Row: Skip left, Get Started right
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip (only if not last page)
                    if (!onLastPage)
                      TextButton(
                        onPressed: () => _controller.jumpToPage(onboardingData.length - 1),
                        child: Text(
                          "Skip",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    else
                      const SizedBox(), // keep layout aligned

                    // Get Started / Next Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.cyanAccent.shade400, Colors.teal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.4),
                            offset: const Offset(0, 6),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (onLastPage) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('onboarding_complete', true);
                            Get.offAllNamed('/SignUpView');
                          } else {
                            _controller.nextPage(
                              duration: 300.ms,
                              curve: Curves.easeInOut,
                            );
                          }
                        },

                        icon: Icon(
                          onLastPage ? Iconsax.tick_circle : Iconsax.arrow_right_3,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: Text(
                          onLastPage ? "Get Started" : "Next",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}
