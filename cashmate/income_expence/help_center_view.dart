import 'package:app/import_export.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> helpTopics = [
      {
        'icon': Iconsax.document_text5,
        'title': 'Getting Started',
        'desc':
        'Learn how to register, set your preferences, and start tracking your money journey with SaveMate.',
      },
      {
        'icon': Iconsax.money_add5,
        'title': 'Adding Income & Expenses',
        'desc':
        'Easily log your income or expense by tapping the "+" button on the dashboard and selecting a category.',
      },
      {
        'icon': Iconsax.arrow_circle_right1,
        'title': 'Saving Goals',
        'desc':
        'Set saving targets like buying a phone or planning a trip. Track progress visually and stay motivated!',
      },
      {
        'icon': Iconsax.chart4,
        'title': 'Understanding Charts',
        'desc':
        'Get insights into your financial habits with detailed pie and bar charts available in the Dashboard.',
      },
      {
        'icon': Iconsax.security_safe5,
        'title': 'Data Privacy',
        'desc':
        'All your data is stored locally on your device. We never access or share your financial information.',
      },
      {
        'icon': Iconsax.cloud_add5,
        'title': 'Offline Access',
        'desc':
        'You can use CashMate even when you are offline. Your entries are saved and synced when online.',
      },
      {
        'icon': Iconsax.setting4,
        'title': 'App Settings',
        'desc':
        'Change themes, manage notifications, update personal info, and more from the Settings screen.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.cyan.shade700,
        title: Text(
          'Help Center',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600,color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Get Help Using CashMate",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
          const SizedBox(height: 16),

          // Help topics
          ...helpTopics.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item['icon'], color: Colors.cyan.shade700, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['desc'],
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3);
          }),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}
