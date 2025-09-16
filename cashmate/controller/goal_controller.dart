
import 'package:app/import_export.dart';

class GoalController extends GetxController {
  final goals = <GoalModel>[].obs;

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedDate = Rxn<DateTime>();

  final txnController = Get.find<TransactionController>();

  GoalModel? editingGoal; // To track current editing item

  /// Add new or update goal
  Future<void> addOrUpdateGoal() async {
    if (titleController.text.isEmpty || amountController.text.isEmpty || selectedDate.value == null) return;

    final goal = GoalModel(
      id: editingGoal?.id, // null if adding
      title: titleController.text.trim(),
      amount: double.tryParse(amountController.text.trim()) ?? 0.0,
      targetDate: selectedDate.value!,
      description: descriptionController.text.trim(),
    );


    if (editingGoal == null) {
      await GoalDBHelper.insertGoal(goal);
    } else {
      await GoalDBHelper.updateGoal(goal);
      editingGoal = null;
    }

    clearForm();
    await getGoals();
  }

  /// Start editing selected goal
  void startEditing(GoalModel goal) {
    editingGoal = goal;
    titleController.text = goal.title;
    amountController.text = goal.amount.toStringAsFixed(2);
    descriptionController.text = goal.description ?? '';
    selectedDate.value = goal.targetDate;
  }
  // void addGoalWithReminder(Goal goal) async {
  //   goalList.add(goal);
  //   update();
  //
  //   await NotificationService.showReminder(
  //     id: goal.id ?? DateTime.now().millisecondsSinceEpoch,
  //     title: "🎯 Goal Reminder",
  //     body: "Don't forget your goal: ${goal.title}",
  //     scheduledTime: goal.reminderDateTime!,
  //     repeatDaily: true,
  //   );
  // }



  /// Delete a goal by ID
  Future<void> deleteGoal(int id) async {
    await GoalDBHelper.deleteGoal(id);
    await getGoals();
  }

  /// Load all goals
  Future<void> getGoals() async {
    final data = await GoalDBHelper.getAllGoals();
    goals.assignAll(data);
  }

  /// Pick target date
  void pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: selectedDate.value ?? DateTime.now(),
    );
    if (date != null) selectedDate.value = date;
  }

  /// Clear form inputs
  void clearForm() {
    titleController.clear();
    amountController.clear();
    descriptionController.clear();
    selectedDate.value = null;
    editingGoal = null;
  }
}
