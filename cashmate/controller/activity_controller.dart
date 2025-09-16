import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:app/import_export.dart';
class ActivityController extends GetxController {
  final DBHelperActivity dbHelper = DBHelperActivity();

  // All activities
  RxList<ActivityModel> allActivities = <ActivityModel>[].obs;

  // Global totals
  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpense = 0.0.obs;

  // Grouped data
  final RxMap<String, List<ActivityModel>> weeklyData = <String, List<ActivityModel>>{}.obs;
  final RxMap<String, List<ActivityModel>> monthlyData = <String, List<ActivityModel>>{}.obs;
  final RxMap<String, List<ActivityModel>> yearlyData = <String, List<ActivityModel>>{}.obs;

  // Grouped totals
  final RxMap<String, double> monthlyIncome = <String, double>{}.obs;
  final RxMap<String, double> monthlyExpense = <String, double>{}.obs;

  Rx<DateTime> selectedDate = DateTime.now().obs;

  // Search
  RxString searchQuery = ''.obs;
  RxBool isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadActivities();

    // Debounce search query
    debounce(searchQuery, (_) {
      update(); // rebuild UI after search
    }, time: const Duration(milliseconds: 300));
  }

  // Load all activities from DB
  Future<void> loadActivities() async {
    final data = await dbHelper.getAllTransactions();
    print("Loaded activities: ${data.length}"); // ✅ debug
    allActivities.assignAll(data.reversed);
    _calculateTotals();
    _groupByWeek();
    _groupByMonth();
    _groupByYear();
  }


  Future<void> addActivity(ActivityModel txn) async {
    // 🔥 Ensure unique ID
    txn.id ??= DateTime.now().millisecondsSinceEpoch;

    await dbHelper.insertTransaction(txn);
    await loadActivities();
  }


  Future<void> deleteActivity(int id) async {
    await dbHelper.deleteTransaction(id);
    await loadActivities();
  }

  // Global totals
  void _calculateTotals() {
    double income = 0;
    double expense = 0;
    for (var activity in allActivities) {
      if (activity.type == "Income") {
        income += activity.amount;
      } else if (activity.type == "Expense") {
        expense += activity.amount;
      }
    }
    totalIncome.value = income;
    totalExpense.value = expense;
  }

  // Group by week
  void _groupByWeek() {
    Map<String, List<ActivityModel>> grouped = {};
    for (var txn in allActivities) {
      final date = txn.date;
      String weekKey = _getWeekKey(date);
      grouped[weekKey] = [...(grouped[weekKey] ?? []), txn];
    }
    weeklyData.assignAll(grouped);
  }

  // Group by month with totals
  void _groupByMonth() {
    Map<String, List<ActivityModel>> grouped = {};
    Map<String, double> incomeTotals = {};
    Map<String, double> expenseTotals = {};

    for (var txn in allActivities) {
      final date = txn.date;
      String monthKey = DateFormat.yMMMM().format(date);

      grouped[monthKey] = [...(grouped[monthKey] ?? []), txn];

      if (txn.type == "Income") {
        incomeTotals[monthKey] = (incomeTotals[monthKey] ?? 0) + txn.amount;
      } else if (txn.type == "Expense") {
        expenseTotals[monthKey] = (expenseTotals[monthKey] ?? 0) + txn.amount;
      }
    }
    monthlyData.assignAll(grouped);
    monthlyIncome.assignAll(incomeTotals);
    monthlyExpense.assignAll(expenseTotals);
  }

  // Group by year
  void _groupByYear() {
    Map<String, List<ActivityModel>> grouped = {};
    for (var txn in allActivities) {
      final date = txn.date;
      String yearKey = DateFormat.y().format(date);
      grouped[yearKey] = [...(grouped[yearKey] ?? []), txn];
    }
    yearlyData.assignAll(grouped);
  }

  // Week key (Mon–Sun)
  String _getWeekKey(DateTime date) {
    final start = date.subtract(Duration(days: date.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return "${DateFormat.MMMd().format(start)} - ${DateFormat.MMMd().format(end)}";
  }

  // ISO week key (Week 1, Week 2...) → optional alternative
  String _getISOWeekKey(DateTime date) {
    int weekOfYear = int.parse(DateFormat("w").format(date));
    return "Week $weekOfYear - ${date.year}";
  }

  // Daily filter
  List<ActivityModel> getActivitiesForSelectedDate() {
    return allActivities.where((txn) {
      return txn.date.year == selectedDate.value.year &&
          txn.date.month == selectedDate.value.month &&
          txn.date.day == selectedDate.value.day;
    }).toList();
  }

  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  // 🔍 Advanced Search
  List<ActivityModel> getFilteredActivities() {
    final query = searchQuery.value.toLowerCase().trim();

    return allActivities.where((txn) {
      final matchDate = DateFormat('yyyy-MM-dd').format(txn.date).contains(query);
      final matchTitle = txn.title?.toLowerCase().contains(query) ?? false;
      final matchCategory = txn.category?.toLowerCase().contains(query) ?? false;
      final matchSubCategory = txn.subCategory?.toLowerCase().contains(query) ?? false;
      final matchAmount = txn.amount.toString().contains(query);

      return matchDate || matchTitle || matchCategory || matchSubCategory || matchAmount;
    }).toList();
  }

  // 📊 Get monthly summary { "Jan 2025": {income: 5000, expense: 3000}, ... }
  Map<String, Map<String, double>> getMonthlySummary() {
    Map<String, Map<String, double>> summary = {};
    monthlyData.forEach((month, txns) {
      double income = 0, expense = 0;
      for (var txn in txns) {
        if (txn.type == "Income") income += txn.amount;
        if (txn.type == "Expense") expense += txn.amount;
      }
      summary[month] = {"income": income, "expense": expense};
    });
    return summary;
  }
}
