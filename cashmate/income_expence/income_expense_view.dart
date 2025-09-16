import 'package:intl/intl.dart';
import 'package:app/import_export.dart';

class IncomeExpenseView extends StatefulWidget {
  const IncomeExpenseView({super.key});

  @override
  State<IncomeExpenseView> createState() => _IncomeExpenseViewState();
}

class _IncomeExpenseViewState extends State<IncomeExpenseView> {
  final controller = Get.put(TransactionController());
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();
  final formKey = GlobalKey<FormState>();
  bool showCategoryList = false;

  String selectedType = 'Income';
  String selectedCategory = '';
  String selectedSubCategory = '';

  TransactionModel? editingTxn; // 👈 yeh rakho

  @override
  void initState() {
    super.initState();

    if (Get.arguments != null && Get.arguments is TransactionModel) {
      editingTxn = Get.arguments as TransactionModel;

      // Prefill form values
      amountController.text = editingTxn!.amount.toString();
      noteController.text = editingTxn!.note ?? '';
      selectedCategory = editingTxn!.category;
      selectedSubCategory = editingTxn!.subcategory ?? '';
      selectedType = editingTxn!.type;
      selectedDateTime = DateTime.tryParse(editingTxn!.date) ?? DateTime.now();
    }
  }

  final incomeCategories = [
    'Salary', 'Business', 'Freelancing', 'Gifts', 'Refunds', 'Bonus',
    'Scholarship', 'Rental Income', 'Stock Dividends', 'Crypto Gains',
    'Pension', 'Side Hustle',
  ];


  final expenseCategories = {
    'Food & Drinks': ['Groceries', 'Dining Out', 'Snacks', 'Coffee', 'Bakery'],
    'Transport': ['Taxi', 'Bus', 'Train', 'Flight', 'Fuel', 'Vehicle Maintenance'],
    'Shopping': ['Clothes', 'Electronics', 'Beauty', 'Footwear', 'Accessories'],
    'Health': ['Medicines', 'Doctor', 'Gym', 'Health Insurance', 'Therapy'],
    'Entertainment': ['Movies', 'Streaming', 'Games', 'Concerts', 'Events'],
    'Education': ['Tuition', 'Books', 'Courses', 'Online Classes', 'Stationery'],
    'Bills & Utilities': ['Electricity', 'Water', 'Internet', 'Gas', 'Phone'],
    'Home': ['Rent', 'Furniture', 'Maintenance', 'Cleaning', 'Home Decor'],
    'Personal Care': ['Salon', 'Spa', 'Skin Care', 'Haircut'],
    'Kids': ['Toys', 'School Fees', 'Clothing', 'Daycare'],
    'Pets': ['Pet Food', 'Vet', 'Grooming', 'Toys'],
    'Travel': ['Accommodation', 'Sightseeing', 'Souvenirs', 'Travel Insurance'],
    'Insurance': ['Life Insurance', 'Vehicle Insurance', 'Health Insurance'],
    'Gifts & Donations': ['Donation', 'Gift', 'Charity', 'Zakat'],
    'Debt & Loans': ['Loan EMI', 'Credit Card Payment', 'Interest Charges'],
    'Work & Office': ['Stationery', 'Software', 'Freelance Expenses', 'Coworking'],
    'Festivals': ['Diwali', 'Christmas', 'Eid', 'Raksha Bandhan', 'Pongal'],
    'Others': ['Uncategorized', 'Miscellaneous'],
  };

  void pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }


  void saveData(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Validation Error",
        "Please fill all required fields.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedCategory.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please select a category.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedType == 'Expense' && selectedSubCategory.isEmpty) {
      Get.snackbar(
        "Validation Error",
        "Please select a subcategory.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    final activityController = Get.find<ActivityController>();

    final txnController = Get.find<TransactionController>();

    if (editingTxn != null) {
      // 🔹 Edit mode
      final updatedTxn = TransactionModel(
        id: editingTxn!.id,
        amount: double.parse(amountController.text.trim()),
        note: noteController.text.trim(),
        category: selectedCategory,
        subcategory: selectedSubCategory,
        type: selectedType,
        date: selectedDateTime.toIso8601String(),
      );

      await txnController.updateTransaction(updatedTxn);

      Get.snackbar(
        "Updated",
        "Transaction updated successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // ✅ Update hone ke baad dashboard par le jao
      Get.offAll(() => DashboardView());
    } else {
      // 🔹 Add mode
      final transaction = TransactionModel(
        amount: double.parse(amountController.text.trim()),
        note: noteController.text.trim(),
        category: selectedCategory,
        subcategory: selectedSubCategory,
        type: selectedType,
        date: selectedDateTime.toIso8601String(),
      );

      await txnController.addTransaction(transaction);

      Get.snackbar(
        "Success",
        "$selectedType saved successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // ✅ Add hone ke baad bhi dashboard par le jao (agar yeh chahiye to)
      Get.offAll(() => DashboardView());
    }

    // 🔹 Reset form
    amountController.clear();
    noteController.clear();
    selectedCategory = '';
    selectedSubCategory = '';
    setState(() {});
  }



  void promptForCategory() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter category name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
          TextButton(
            child: const Text("Add"),
            onPressed: () {
              final newCat = controller.text.trim();
              if (newCat.isNotEmpty) {
                setState(() {
                  if (selectedType == 'Income') {
                    incomeCategories.add(newCat);

                  } else {
                    expenseCategories[newCat] = [];
                  }
                  selectedCategory = newCat;
                });
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void promptForSubcategory() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Subcategory"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter subcategory name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
          TextButton(
            child: const Text("Add"),
            onPressed: () {
              final newSub = controller.text.trim();
              if (newSub.isNotEmpty) {
                setState(() {
                  expenseCategories[selectedCategory] ??= [];
                  expenseCategories[selectedCategory]!.add(newSub);
                  selectedSubCategory = newSub;
                });
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("💸 Add Transaction", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Animate(
          effects: [FadeEffect(duration: 400.ms), SlideEffect()],
          child: Form(
            key: formKey,
            child: Card(
              elevation: 14,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildDropdown(
                      label: "Type",
                      value: selectedType,
                      items: ['Income', 'Expense',]
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedType = val!;
                          selectedCategory = '';
                          selectedSubCategory = '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: amountController,
                      label: "Amount",
                      icon: Icons.currency_rupee, // ✅ Rupee symbol icon
                      inputType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter amount';
                        if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    buildDateRow(),
                    const SizedBox(height: 16),
                    buildCategorySection(),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: noteController,
                      label: "Note (optional)",
                      icon: Iconsax.note_text,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),
                    buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      validator: validator,
    );
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isNotEmpty ? value : null,
      items: items,
      onChanged: onChanged,
      validator: isRequired ? (val) => (val == null || val.isEmpty) ? 'Please select $label' : null : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget buildDateRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "📅 ${DateFormat.yMMMMd().add_jm().format(selectedDateTime)}",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        GestureDetector(
          onTap: pickDateTime,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Iconsax.calendar, color: Colors.deepPurple),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(end: 1.1, duration: 600.ms),
        ),
      ],
    );
  }

  Widget buildCategorySection() {

    final categories = selectedType == 'Income'
        ? incomeCategories
        : expenseCategories.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Category", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            TextButton.icon(
              icon: Icon(showCategoryList ? Iconsax.arrow_up_1 : Iconsax.arrow_down_1, size: 18),
              label: Text(showCategoryList ? "Hide" : "Select", style: GoogleFonts.poppins(fontSize: 13)),
              onPressed: () => setState(() => showCategoryList = !showCategoryList),
            )
          ],
        ),
        const SizedBox(height: 10),
        if (showCategoryList)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      labelStyle: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.black),
                      selected: isSelected,
                      selectedColor: selectedType == 'Income'
                          ? Colors.green
                          : selectedType == 'Saving'
                          ? Colors.indigo
                          : Colors.deepOrangeAccent,
                      backgroundColor: Colors.grey[200],
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = cat;
                          selectedSubCategory = '';
                        });
                      },
                    );
                  }),
                  ActionChip(
                    avatar: const Icon(Iconsax.add, size: 18),
                    label: const Text("Add New"),
                    onPressed: promptForCategory,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (selectedType == 'Expense' && selectedCategory.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Subcategory", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...expenseCategories[selectedCategory]!.map((sub) {
                          final isSelected = selectedSubCategory == sub;
                          return ChoiceChip(
                            label: Text(sub),
                            labelStyle: GoogleFonts.poppins(color: isSelected ? Colors.white : Colors.black),
                            selected: isSelected,
                            selectedColor: Colors.redAccent,
                            backgroundColor: Colors.grey[200],
                            onSelected: (_) => setState(() => selectedSubCategory = sub),
                          );
                        }),
                        ActionChip(
                          avatar: const Icon(Iconsax.add, size: 18),
                          label: const Text("Add Sub"),
                          onPressed: promptForSubcategory,
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
      ],
    );
  }


  Widget buildSaveButton() {
    final colors = selectedType == 'Income'
        ? [Colors.green, Colors.teal]
        : selectedType == 'Saving'
        ? [Colors.blue, Colors.indigo]
        : [Colors.redAccent, Colors.deepOrange];

    return AnimatedContainer(
      duration: 400.ms,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ],
      ),
      child: ElevatedButton.icon(
        icon: const Icon(Iconsax.save_2, color: Colors.white),
        // label: Text(
        //   "Save $selectedType",
        //   style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        // ),
        label: Text(
          editingTxn != null ? "Update $selectedType" : "Save $selectedType",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () => saveData(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
    );
  }
}
