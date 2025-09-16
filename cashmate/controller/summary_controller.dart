import 'package:get/get.dart';
import '../income_expence/db_helper_summury.dart';
import '../model/activity_model.dart';

class ActivityController extends GetxController {
  final DBHelperActivity dbHelper = DBHelperActivity();

  final RxList<ActivityModel> _allActivities = <ActivityModel>[].obs;
  List<ActivityModel> get allActivities => _allActivities;

  RxDouble totalIncome = 0.0.obs;
  RxDouble totalExpense = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    final activities = await dbHelper.getAllActivities();
    _allActivities.assignAll(activities);
    calculateTotals();
  }

  Future<void> addActivity(ActivityModel activity) async {
    await dbHelper.insertActivity(activity);
    await fetchActivities();
  }

  Future<void> updateActivity(ActivityModel activity) async {
    await dbHelper.updateActivity(activity);
    await fetchActivities();
  }

  Future<void> deleteActivity(int id) async {
    await dbHelper.deleteActivity(id);
    await fetchActivities();
  }

  void calculateTotals() {
    totalIncome.value = _allActivities
        .where((a) => a.type == "Income")
        .fold(0.0, (sum, a) => sum + a.amount);

    totalExpense.value = _allActivities
        .where((a) => a.type == "Expense")
        .fold(0.0, (sum, a) => sum + a.amount);
  }

  // 🔹 Filter Data
  List<ActivityModel> getMonthlyData(DateTime month) {
    return _allActivities.where((a) =>
    a.date.year == month.year && a.date.month == month.month).toList();
  }

  List<ActivityModel> getWeeklyData(DateTime weekDate) {
    final weekStart = weekDate.subtract(Duration(days: weekDate.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return _allActivities
        .where((a) => a.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        a.date.isBefore(weekEnd.add(const Duration(days: 1))))
        .toList();
  }

  List<ActivityModel> getYearlyData(int year) {
    return _allActivities.where((a) => a.date.year == year).toList();
  }

  // 🔹 Totals
  Map<String, double> getMonthlyTotals(DateTime month) {
    final data = getMonthlyData(month);
    return _calculateIncomeExpense(data);
  }

  Map<String, double> getWeeklyTotals(DateTime weekDate) {
    final data = getWeeklyData(weekDate);
    return _calculateIncomeExpense(data);
  }

  Map<String, double> getYearlyTotals(int year) {
    final data = getYearlyData(year);
    return _calculateIncomeExpense(data);
  }

  // Helper
  Map<String, double> _calculateIncomeExpense(List<ActivityModel> data) {
    final income = data
        .where((a) => a.type == "Income")
        .fold(0.0, (sum, a) => sum + a.amount);
    final expense = data
        .where((a) => a.type == "Expense")
        .fold(0.0, (sum, a) => sum + a.amount);
    return {"income": income, "expense": expense};
  }
}
