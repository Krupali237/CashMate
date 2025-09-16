import 'dart:io';
import 'package:intl/intl.dart';
import 'package:app/import_export.dart';

class DashboardView extends StatefulWidget {
  DashboardView({Key? key}) : super(key: key);
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final UserController userController = Get.put(UserController());
  final TransactionController txnController = Get.put(TransactionController());
  final ThemeController themeController = Get.find<ThemeController>();


  int _selectedIndex = 0;
  String? userEmail;
  String? userName;
  //final String customTitle = "Smart Expense Tracker 💸";
  late final List<Widget> pages;

  File? _profileImage;

// Load image path from SharedPreferences
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');
    if (path != null) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

// Pick image from gallery and save
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', picked.path);
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }
  String formatCurrency(double value) {
    final formatter = NumberFormat('#,##0', 'en_IN'); // India style commas
    return formatter.format(value);
  }



  @override
  void initState() {
    super.initState();
    txnController.loadData();
    userController.loadCurrentUser();
    _loadProfileImage(); // Load previously selected image


    pages = [
      _buildHomePage(),  // index 0
      SizedBox(),        // index 1
      SizedBox(),        // index 2
      GroupListView(),
      SettingsView(),    // index 4
    ];

  }
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString("user_email") ?? "No Email";
      userName = prefs.getString("user_name") ?? "Guest";
    });
  }


  void _onTabTapped(int index) {
    if (index == 2) {
      // FAB pressed, open IncomeExpenseView via Get.to
      Get.to(() => const IncomeExpenseView());
      return;
    }


    setState(() {
      _selectedIndex = index;
    });
  }

  
  Map<String, double> _getCategoryExpenseMap() {
    final txns = txnController.transactions;
    final Map<String, double> data = {};

    for (var txn in txns) {
      if (txn.type == 'Expense') {
        data[txn.category] = (data[txn.category] ?? 0) + txn.amount;
      }
    }

    return data;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // iconTheme: Theme.of(context).appBarTheme.iconTheme,

      extendBody: true,
      drawer: _buildDrawer(),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          Get.to(() => IncomeExpenseView());
        },
        child: Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xC833A0B2), Color(0xFF181616)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 5)),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 36),
        ),
      ),

      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),


      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 20,
        color: Colors.white.withOpacity(0.05),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.05)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _navBarItem(icon: Icons.home_rounded,label: 'Home', index: 0),
                 // const SizedBox(width: 20),
                 // _navBarItem(icon: Icons.savings_sharp, index: 1),
                ],
              ),
              Row(
                children: [
                  //_navBarItem(icon: Icons.history_rounded, index: 3),
                  //const SizedBox(width: 20),
                  _navBarItem(icon: Icons.group_add,label: 'Split', index: 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _navBarItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan.shade50.withOpacity(0.6) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? Colors.cyan.shade800 : Colors.grey.shade500,
            ),
            const SizedBox(width: 8),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Text(
                label,
                style: TextStyle(
                  color: Colors.cyan.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Obx(() {
      final txns = txnController.transactions;
      return Column(

        children: [

          AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
            elevation: 0,
            centerTitle: true,
            leading: Builder(
              builder: (context) => InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top line
                      Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [Colors.cyan.shade300, Colors.cyan.shade900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Middle line
                      Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [Colors.cyan.shade400, Colors.cyan.shade800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Bottom line
                      Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [Colors.cyan.shade500, Colors.cyan.shade700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            title: Text(
              "Smart Expense Tracker 💸",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0A500), Color(0xFFE67E22)], // golden-orange calculator vibe
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 22),
                ),
                onPressed: () {
                  Get.to(() => calculatornewPage());
                },
              ),

            ],
          ),


          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xC81593A8), Color(0xC8101313)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Balance",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "₹ ${formatCurrency(txnController.totalIncome - txnController.totalExpense)}",
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _balanceItem("Income", txnController.totalIncome, Colors.greenAccent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _balanceItem("Expenses", txnController.totalExpense, Colors.redAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (txns.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text("No transactions", style: GoogleFonts.poppins()),
                      ),
                    )
                  else ...[
                    buildExpenseBarChart(_getCategoryExpenseMap(), txnController.totalIncome),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: txns.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (_, index) {
                        final txn = txns[index];
                        final icon = _getCategoryIcon(txn.category);
                        final color = txn.type == "Income" ? Colors.green : Colors.red;

                        // Format date + time
                        final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(txn.date));
                        final formattedAmount = NumberFormat.decimalPattern('en_IN').format(txn.amount);

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          shadowColor: color.withOpacity(0.2),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: color.withOpacity(0.15),
                              child: Icon(icon, color: color, size: 26),
                            ),
                            title: Text(
                              txn.category,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (txn.subcategory != null && txn.subcategory!.isNotEmpty)
                                  Text(
                                    txn.subcategory!,
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                                  ),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${txn.type == "Income" ? "+" : "-"} ₹$formattedAmount",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Get.toNamed('/IncomeExpenseView', arguments: txn);
                                    } else if (value == 'delete') {
                                      _confirmDelete(txn.id!);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(children: [
                                          Icon(Icons.edit, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text("Edit")
                                        ])),
                                    const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text("Delete")
                                        ])),
                                  ],
                                  icon: const Icon(Icons.more_vert),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // ✅ Balance item widget
  // Widget _balanceItem(String title, double value, Color color) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Text(
  //         title,
  //         style: TextStyle(
  //           fontWeight: FontWeight.bold,
  //           fontSize: 16,
  //           color: color, // Title white
  //         ),
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         "₹ ${formatCurrency(value)}",
  //         style: TextStyle(
  //           color: color, // Amount white
  //           fontSize: 18,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _balanceItem(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            title == "Income" ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "₹ ${formatCurrency(value)}",
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }


  Widget buildExpenseBarChart(Map<String, double> categoryExpenses, double totalIncome) {
    if (categoryExpenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "No expense data available",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );
    }

    final double dailyLimit = totalIncome / 30;
    final sortedEntries = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final double maxValue = sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final double yInterval = (maxValue / 4).ceilToDouble();
    final Color defaultBarColor = Colors.teal;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily Expenses",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                maxY: maxValue + yInterval,
                minY: 0,
                barGroups: List.generate(sortedEntries.length, (index) {
                  final entry = sortedEntries[index];
                  final isOverLimit = entry.value > dailyLimit;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        width: 20,
                        borderRadius: BorderRadius.circular(8),
                        color: isOverLimit ? Colors.red : null,
                        gradient: isOverLimit
                            ? null
                            : LinearGradient(
                          colors: [
                            defaultBarColor.withOpacity(0.9),
                            defaultBarColor.withOpacity(0.6)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxValue + yInterval,
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: yInterval,
                      getTitlesWidget: (value, _) => Text(
                        '₹${value.toInt()}',
                        style: GoogleFonts.poppins(fontSize: 10,   color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < sortedEntries.length) {
                          final categoryName = sortedEntries[index].key.split(' - ').first;
                          return Transform.rotate(
                            angle: -0.4,
                            child: Text(
                              categoryName,
                              style: GoogleFonts.poppins(fontSize: 10,  color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Daily Limit: ₹${formatCurrency(dailyLimit)}",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [

            Obx(() {
              final user = userController.currentUser.value;
              final name = user?.name ?? "Welcome";

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xC81593A8), Color(0xC89AD3D3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6A85B6), Color(0xFFBAC8E0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage:
                          _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null
                              ? Icon(Icons.person, size: 40, color: Colors.grey.shade600)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    /// ✅ User Name
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// ✅ Unique App-Centric Subtitle
                    Text(
                      "Money moves💸, vibes up🤑", // <-- Replace with any Gen-Z line or make it dynamic
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }),

            /// ✅ Drawer Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _lightDrawerItem(Icons.track_changes_sharp, "My Goals",
                          () => Get.to(() => GoalView())),
                  _lightDrawerItem(
                      Icons.group, "History", () => Get.to(() => RecordView())),
                  _lightDrawerItem(Icons.lightbulb_sharp, "Knowledge Center",
                          () => Get.to(() => KnowledgeCenterView())),
                  // _lightDrawerItem(Icons.person, "Create New Account",
                  //         () => Get.to(() => const SignUpView())),


                  _lightDrawerItem(Icons.help, "Help Center",
                          () => Get.to(() => HelpCenterView())),
                  _lightDrawerItem(Icons.feedback_sharp, "Feedback",
                          () => Get.to(() => FeedbackPage())),
                  _lightDrawerItem(Icons.account_box, "About Us",
                          () => Get.to(() => AboutUs())),
                  _lightDrawerItem(Icons.settings, "Settings",
                          () => Get.to(() => SettingsView())),

                  const SizedBox(height: 20),

                  /// 🚨 Logout Highlight
                  _lightDrawerItem(Icons.logout_sharp, "Logout", () async {
                    Get.dialog(
                      Center(
                        child: Container(
                          width: Get.width * 0.8,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout, size: 48, color: Colors.redAccent),
                              const SizedBox(height: 16),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Are you sure you want to logout from your account?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Cancel Button
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.grey.shade400),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () => Get.back(),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Logout Button
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.setBool('isLoggedIn', false);
                                        Get.back();
                                        await Future.delayed(const Duration(milliseconds: 500));
                                        Get.offAll(() => const LoginView());
                                      },
                                      child: Text(
                                        "Logout",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
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
                  }, color: Colors.redAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🌸 Pastel/Light Drawer Item
  Widget _lightDrawerItem(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.cyan.shade700, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }


  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    final contextColor = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: color ?? contextColor.iconTheme.color),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 15,color: color ?? contextColor.textTheme.bodyMedium?.color,
      )),
      onTap: onTap,
    );
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase().trim();

    if (cat.contains("food") || cat.contains("grocery")) return Icons.fastfood;
    if (cat.contains("shop") || cat.contains("clothes")) return Icons.shopping_bag;
    if (cat.contains("entertainment") || cat.contains("movie") || cat.contains("netflix")) return Icons.movie;
    if (cat.contains("travel") || cat.contains("trip") || cat.contains("transport")) return Icons.flight_takeoff;
    if (cat.contains("health") || cat.contains("doctor") || cat.contains("medicine")) return Icons.local_hospital;
    if (cat.contains("salary") || cat.contains("income") || cat.contains("job")) return Icons.account_balance_wallet;
    if (cat.contains("freelance") || cat.contains("project")) return Icons.laptop_mac;
    if (cat.contains("bills") || cat.contains("utilities") || cat.contains("rent")) return Icons.receipt_long;
    if (cat.contains("gift") || cat.contains("reward")) return Icons.card_giftcard;
    if (cat.contains("education") || cat.contains("study")) return Icons.school;
    if (cat.contains("investment") || cat.contains("stock")) return Icons.trending_up;
    if (cat.contains("others")) return Icons.category;

    return Icons.category;
  }


  void _confirmDelete(int id) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever, color: Colors.red, size: 48),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Delete Transaction?",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                "Are you sure you want to permanently delete this transaction? This action cannot be undone.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel button
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text("Cancel", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),

                  // Delete button
                  ElevatedButton(
                    onPressed: () {
                      txnController.deleteTransaction(id);
                      Get.back();
                      Get.snackbar(
                        "Deleted",
                        "Transaction has been deleted successfully",
                        backgroundColor: Colors.red.withOpacity(0.1),
                        colorText: Colors.red,
                        icon: const Icon(Icons.delete, color: Colors.red),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text("Delete", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
