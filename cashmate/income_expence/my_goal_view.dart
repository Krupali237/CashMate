import 'package:app/import_export.dart';

class GoalView extends StatelessWidget {
  final GoalController controller = Get.put(GoalController());

  @override
  Widget build(BuildContext context) {
    controller.getGoals(); // fetch on open

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text('🎯 My Goals',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600,color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.cyan.shade700,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.clearForm(); // reset for add
          _showGoalSheet(context, isEdit: false);
        },
        child: Icon(Iconsax.add),
        backgroundColor: Colors.cyan.shade700,
      ),
      body: Obx(() {
        if (controller.goals.isEmpty) {
          return Center(
            child: Text("No Goals Yet 📝",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: controller.goals.length,
          itemBuilder: (context, index) {
            final goal = controller.goals[index];
            final dailyNeed = goal.getDailySavingRequired(DateTime.now());

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(goal.title,
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, fontWeight: FontWeight.w600)),
                              SizedBox(height: 6),
                              Text("🎯 Amount: ₹${goal.amount.toStringAsFixed(2)}",
                                  style: GoogleFonts.poppins(fontSize: 14,color: Colors.black)),
                              Text("📅 Target: ${goal.targetDate.toLocal().toString().split(' ')[0]}",
                                  style: GoogleFonts.poppins(fontSize: 14,color: Colors.black)),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                controller.startEditing(goal);
                                _showGoalSheet(context, isEdit: true);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                              onPressed: () {
                                Get.dialog(
                                  Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.8,
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
                                          Icon(Icons.delete_forever, size: 48, color: Colors.redAccent),
                                          const SizedBox(height: 16),
                                          Text(
                                            "Delete Goal?",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Are you sure you want to delete this goal? ",
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
                                                    style: TextStyle(color: Colors.grey[800], fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              // Confirm Delete Button
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    backgroundColor: Colors.redAccent,
                                                  ),
                                                  onPressed: () {
                                                    controller.deleteGoal(goal.id!);
                                                    Get.back();
                                                  },
                                                  child: Text(
                                                    "Delete",
                                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    if (goal.description != null && goal.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("📝 ${goal.description}",
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
                      ),
                    Divider(height: 20, thickness: 1),
                    Text("💰 Save ₹${dailyNeed.toStringAsFixed(2)} / day",
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w500, color: Colors.green[700])),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.1, duration: 400.ms);
          },
        );
      }),
    );
  }

  void _showGoalSheet(BuildContext context, {required bool isEdit}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? "Edit Goal" : "Add Goal",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
              ),
              SizedBox(height: 12),
              _buildTextField(controller.titleController, "Goal Title", Iconsax.edit),
              _buildTextField(controller.amountController, "Goal Amount (₹)", Iconsax.money,
                  inputType: TextInputType.number),
              _buildTextField(controller.descriptionController, "Description", Iconsax.note_1),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Iconsax.calendar, color: Colors.cyan.shade700),
                  SizedBox(width: 8),
                  Obx(() {
                    return Text(
                      controller.selectedDate.value != null
                          ? controller.selectedDate.value!.toLocal().toString().split(' ')[0]
                          : "Select Target Date",
                      style: GoogleFonts.poppins(fontSize: 14),
                    );
                  }),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => controller.pickDate(context),
                    child: Text("Pick Date",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan.shade700),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Iconsax.save_2,color: Colors.white,),
                  label: Text(isEdit ? "Update Goal" : "Add Goal",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold,color: Colors.white,)),
                  onPressed: () {
                    controller.addOrUpdateGoal();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    backgroundColor: Colors.cyan.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.cyan.shade700),
          hintText: hint,
          filled: true,
          fillColor: Colors.deepPurple.shade50,
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
