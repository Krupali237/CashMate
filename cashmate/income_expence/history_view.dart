import 'package:intl/intl.dart';
import 'package:app/import_export.dart';

class RecordView extends StatefulWidget {
  const RecordView({Key? key}) : super(key: key);

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  final TransactionController controller = Get.find<TransactionController>();

  String selectedFilter = "Month";
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  final TextEditingController searchCtrl = TextEditingController();

  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    controller.loadData();
    selectedDay = DateTime.now();
    focusedDay = DateTime.now();
  }

  /// ✅ Filter + Search transactions
  List<TransactionModel> getFilteredTransactions({String? mode}) {
    List<TransactionModel> baseList;
    DateTime refDate = selectedDay ?? DateTime.now();

    if ((mode ?? selectedFilter) == "Week") {
      final startOfWeek = refDate.subtract(Duration(days: refDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      baseList = controller.transactions.where((t) {
        final txnDate = DateTime.parse(t.date);
        return txnDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            txnDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      }).toList();
    } else if ((mode ?? selectedFilter) == "Month") {
      baseList = controller.transactions.where((t) {
        final txnDate = DateTime.parse(t.date);
        return txnDate.month == refDate.month && txnDate.year == refDate.year;
      }).toList();
    } else if ((mode ?? selectedFilter) == "Year") {
      baseList = controller.transactions.where((t) {
        final txnDate = DateTime.parse(t.date);
        return txnDate.year == refDate.year;
      }).toList();
    } else {
      baseList = controller.transactions;
    }

    // ✅ Apply search filter only in list view
    if (mode == null) {
      final query = searchCtrl.text.toLowerCase().trim();
      if (query.isNotEmpty) {
        baseList = baseList.where((t) {
          final txnDate =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(t.date));
          return t.category.toLowerCase().contains(query) ||
              t.subcategory.toLowerCase().contains(query) ||
              t.note.toLowerCase().contains(query) ||
              txnDate.contains(query);
        }).toList();
      }
    }

    return baseList;
  }

  /// ✅ Build Pie Chart Data (Gen-Z style – gradient & no labels inside)
  /// ✅ Build Pie Chart Data (with neon gradients & no labels)
  List<PieChartSectionData> buildPieData(
      List<TransactionModel> txns, List<Color> colors) {
    Map<String, double> categoryTotals = {};

    for (var txn in txns) {
      final key = "${txn.type} - ${txn.category}";
      categoryTotals[key] = (categoryTotals[key] ?? 0) + txn.amount;
    }

    int colorIndex = 0;
    return categoryTotals.entries.map((e) {
      final baseColor = colors[colorIndex % colors.length];
      final section = PieChartSectionData(
        value: e.value,
        title: '',
        radius: 75,
        color: baseColor,
        badgeWidget: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [baseColor.withOpacity(0.95), baseColor.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(2, 3),
              ),
            ],
          ),
        ),
        badgePositionPercentageOffset: 1.25,
      );
      colorIndex++;
      return section;
    }).toList();
  }

  /// ✅ Animated Modern Legend (Gen-Z chip style)
  Widget buildLegend(Map<String, double> data, List<Color> colors) {
    int i = 0;
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: data.entries.map((e) {
        final color = colors[i % colors.length];
        i++;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.95), color.withOpacity(0.65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(3, 4),
              )
            ],
          ),
          child: Text(
            "${e.key.split(" - ")[1]}  ₹${e.value.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// ✅ Show Bottom Sheet with Glassmorphism + Pie Chart
  void showCharts() {
    final colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.pinkAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.cyanAccent,
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Drag Handle
            Container(
              height: 6,
              width: 60,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            /// Title
            const Text(
              "💹 Income & Expense Breakdown",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 20),

            /// Horizontal Scrollable Chart Cards
            SizedBox(
              height: 400,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ["Week", "Month", "Year"].map((mode) {
                  final txns = getFilteredTransactions(mode: mode);

                  /// Data for legend
                  Map<String, double> categoryTotals = {};
                  double totalAmount = 0;
                  for (var txn in txns) {
                    final key = "${txn.type} - ${txn.category}";
                    categoryTotals[key] =
                        (categoryTotals[key] ?? 0) + txn.amount;
                    totalAmount += txn.amount;
                  }

                  return Container(
                    width: 320,
                    margin: const EdgeInsets.only(right: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(3, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          mode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),

                        /// Pie Chart
                        Expanded(
                          child: (txns.isEmpty)
                              ? Center(
                              child: Text("No data",
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14)))
                              : Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: buildPieData(txns, colors),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 55,
                                  borderData: FlBorderData(show: false),
                                ),
                                swapAnimationDuration:
                                const Duration(milliseconds: 700),
                                swapAnimationCurve: Curves.easeInOutCubic,
                              ),

                              /// Center Text (Total)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("Total",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54)),
                                  Text(
                                    "₹${totalAmount.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        /// Legend
                        if (categoryTotals.isNotEmpty)
                          buildLegend(categoryTotals, colors),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }



  /// ✅ Build Legend

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f6ff),
      appBar: AppBar(
        title: const Text("📊 Records",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_rounded, color: Colors.black87),
            onPressed: showCharts, // ✅ Show charts
          ),
          PopupMenuButton<String>(
            onSelected: (val) => setState(() => selectedFilter = val),
            itemBuilder: (_) => ["Week", "Month", "Year"]
                .map((e) => PopupMenuItem(value: e, child: Text(e)))
                .toList(),
            icon: const Icon(Icons.filter_alt_rounded, color: Colors.black87),
          )
        ],
      ),
      body: Obx(() {
        final filtered = getFilteredTransactions();

        return Column(
          children: [
            const SizedBox(height: 8),

            /// ✅ Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextField(
                controller: searchCtrl,
                decoration: InputDecoration(
                  hintText: "🔍 Search by note, date, category, subcategory",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            /// ✅ Calendar
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: focusedDay,
                  calendarFormat: _calendarFormat,
                  availableCalendarFormats: const {
                    CalendarFormat.week: "Week",
                    CalendarFormat.month: "Month"
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    formatButtonShowsNext: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  selectedDayPredicate: (day) =>
                  selectedDay != null &&
                      DateFormat('yyyy-MM-dd').format(day) ==
                          DateFormat('yyyy-MM-dd').format(selectedDay!),
                  onDaySelected: (selected, focus) {
                    setState(() {
                      selectedDay = selected;
                      focusedDay = focus;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  onPageChanged: (focused) =>
                      setState(() => focusedDay = focused),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xC833A0B2), Color(0xFF181616)],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            /// ✅ Transactions List
            Expanded(
              child: (filtered.isEmpty)
                  ? Center(
                child: Text(
                  "No matching transactions",
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final txn = filtered[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        /// Icon Avatar
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: txn.type == "Income"
                              ? Colors.green.withOpacity(0.15)
                              : txn.type == "Expense"
                              ? Colors.red.withOpacity(0.15)
                              : Colors.blue.withOpacity(0.15),
                          child: Icon(
                            txn.type == "Income"
                                ? Icons.arrow_downward_rounded
                                : txn.type == "Expense"
                                ? Icons.arrow_upward_rounded
                                : Icons.savings_rounded,
                            color: txn.type == "Income"
                                ? Colors.green
                                : txn.type == "Expense"
                                ? Colors.red
                                : Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),

                        /// Middle Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${txn.category} - ${txn.subcategory}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.note_alt_outlined,
                                      size: 14,
                                      color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(txn.note,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        /// Amount + Badge
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${NumberFormat("#,##0", "en_IN").format(txn.amount)}",
                              style: TextStyle(
                                color: txn.type == "Income"
                                    ? Colors.green
                                    : txn.type == "Expense"
                                    ? Colors.red
                                    : Colors.blue,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: txn.type == "Income"
                                    ? Colors.green.withOpacity(0.1)
                                    : txn.type == "Expense"
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                txn.type == "Income"
                                    ? "💸 In"
                                    : txn.type == "Expense"
                                    ? "💰 Out"
                                    : "🏦 Save",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: txn.type == "Income"
                                        ? Colors.green
                                        : txn.type == "Expense"
                                        ? Colors.red
                                        : Colors.blue),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
