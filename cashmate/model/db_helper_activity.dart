import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/activity_model.dart';

class DBHelperActivity {
  static const String key = "activities";

  /// Insert a new transaction
  Future<void> insertTransaction(ActivityModel activity) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = prefs.getString(key);

    List<ActivityModel> currentList = [];

    if (existingData != null) {
      List decoded = jsonDecode(existingData);
      currentList = decoded.map((e) => ActivityModel.fromJson(e)).toList();
    }

    // 🔥 Unique ID generate karo agar null ho
    if (activity.id == null) {
      activity = ActivityModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: activity.title,
        type: activity.type,
        amount: activity.amount,
        date: activity.date,
        category: activity.category,
        subCategory: activity.subCategory,
      );
    }

    currentList.add(activity);

    final encoded = jsonEncode(currentList.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  /// Get all transactions
  Future<List<ActivityModel>> getAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data != null) {
      List decoded = jsonDecode(data);
      return decoded.map((e) => ActivityModel.fromJson(e)).toList();
    }
    return [];
  }

  /// Delete transaction by ID
  Future<void> deleteTransaction(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data != null) {
      List decoded = jsonDecode(data);
      List<ActivityModel> activities = decoded.map((e) => ActivityModel.fromJson(e)).toList();

      activities.removeWhere((txn) => txn.id == id);

      final encoded = jsonEncode(activities.map((e) => e.toJson()).toList());
      await prefs.setString(key, encoded);
    }
  }

  /// Update transaction by ID
  Future<void> updateTransaction(ActivityModel updatedActivity) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data != null) {
      List decoded = jsonDecode(data);
      List<ActivityModel> activities = decoded.map((e) => ActivityModel.fromJson(e)).toList();

      int index = activities.indexWhere((txn) => txn.id == updatedActivity.id);
      if (index != -1) {
        activities[index] = updatedActivity;
      }

      final encoded = jsonEncode(activities.map((e) => e.toJson()).toList());
      await prefs.setString(key, encoded);
    }
  }

  /// Clear all transactions
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
