
import 'package:app/import_export.dart';

class KnowledgeCenterView extends StatelessWidget {
  const KnowledgeCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> knowledgeList = [
      {
        'title': 'What is CashMate?',
        'desc':
        'CashMate is your smart personal finance assistant to manage income, expenses, savings goals, and budgets with style and simplicity.',
        'icon': Iconsax.wallet_check,
        'color': Colors.teal,
      },
      {
        'title': 'How to Add Income or Expense?',
        'desc':
        'Tap the "+" button on Dashboard > Choose Income or Expense > Fill the form with category, amount, note > Tap Save.',
        'icon': Iconsax.add_circle,
        'color': Colors.orange,
      },
      {
        'title': 'Set Smart Goals',
        'desc':
        'Create savings goals like "New Phone" or "Trip to Goa" and track your progress with live updates and percentages.',
        'icon': Iconsax.arrange_circle,
        'color': Colors.purple,
      },
      {
        'title': 'Visual Charts & Analysis',
        'desc':
        'Beautiful pie and bar charts provide insights into your income, spending habits, and progress toward your goals.',
        'icon': Iconsax.chart,
        'color': Colors.indigo,
      },
      {
        'title': 'Dark Mode & Themes',
        'desc':
        'Switch between Light and Dark modes for better visibility and comfort. Personalize with theme settings.',
        'icon': Iconsax.moon,
        'color': Colors.blueGrey,
      },
      {
        'title': 'Offline First',
        'desc':
        'No internet? No problem! SaveMate stores your financial data securely on your device so you can track anywhere.',
        'icon': Iconsax.wifi_square,
        'color': Colors.brown,
      },
      {
        'title': 'Your Data = Your Privacy',
        'desc':
        'Your financial data is never uploaded or shared. Everything remains secure and private on your phone only.',
        'icon': Iconsax.shield_tick,
        'color': Colors.green,
      },
      {
        'title': 'Reminders & Notifications',
        'desc':
        'Set smart reminders to add transactions, update goals, or check savings progress regularly.',
        'icon': Iconsax.notification,
        'color': Colors.redAccent,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.cyan.shade700,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Knowledge Center',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600,color: Colors.white),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "📘 Learn more about CashMate",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.cyan.shade700,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
          const SizedBox(height: 16),

          ...knowledgeList.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: (item['color'] as Color).withOpacity(0.1),
                  child: Icon(item['icon'], color: item['color']),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['desc'],
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3)),
        ],
      ),
    );
  }
}
