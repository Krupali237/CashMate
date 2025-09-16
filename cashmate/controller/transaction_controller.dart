


import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/transaction_model.dart';
import '../income_expence/db_helper_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionController extends GetxController {
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<String> savingCategories = <String>[].obs;

  final DBHelper dbHelper = DBHelper();

  double get totalIncome => transactions
      .where((e) => e.type == 'Income')
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense => transactions
      .where((e) => e.type == 'Expense')
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalSavings => transactions
      .where((e) => e.type == 'Saving')
      .fold(0.0, (sum, e) => sum + e.amount);

  Future<void> loadData() async {
    final data = await dbHelper.getAll();
    transactions.assignAll(data);
  }

  Future<void> addTransaction(TransactionModel model) async {
    await dbHelper.insert(model);
    await loadData();
  }

  Future<void> updateTransaction(TransactionModel model) async {
    await dbHelper.update(model);
    await loadData();
  }

  Future<void> deleteTransaction(int id) async {
    await dbHelper.delete(id);
    await loadData();
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList =
        prefs.getStringList('saving_categories') ?? ['Bank', 'Wallet', 'FD'];
    savingCategories.assignAll(savedList);
  }

  Future<void> addCategory(String category) async {
    if (!savingCategories.contains(category)) {
      savingCategories.add(category);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saving_categories', savingCategories);
    }
  }

  // ------------------ DATE WISE FILTERS ------------------

  /// Day-wise transactions (today)
  List<TransactionModel> getTodayTransactions() {
    final today = DateTime.now();
    return transactions.where((txn) {
      final date = DateTime.parse(txn.date);
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();
  }

  /// Week-wise transactions (this week Mon-Sun)
  List<TransactionModel> getWeekTransactions() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return transactions.where((txn) {
      final date = DateTime.parse(txn.date);
      return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  /// Month-wise transactions (current month)
  List<TransactionModel> getMonthTransactions() {
    final now = DateTime.now();
    return transactions.where((txn) {
      final date = DateTime.parse(txn.date);
      return date.year == now.year && date.month == now.month;
    }).toList();
  }

  /// Year-wise transactions (current year)
  List<TransactionModel> getYearTransactions() {
    final now = DateTime.now();
    return transactions.where((txn) {
      final date = DateTime.parse(txn.date);
      return date.year == now.year;
    }).toList();
  }
}
