import 'dart:ui';
import 'package:app/import_export.dart';
import 'package:intl/intl.dart';



String formatRupees(num value) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0, // no decimals
  );
  return formatter.format(value);
}



// ---------------- GROUP LIST -----------------
class GroupListView extends StatelessWidget {
  final controller = Get.put(GroupController());
  final nameCtrl = TextEditingController();
  final placeCtrl = TextEditingController();
  final ThemeController themeController = Get.find<ThemeController>();


  @override
  Widget build(BuildContext context) {
    controller.loadGroups();
    return Scaffold(
      appBar: AppBar(
        title: Text("💼 My Groups", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                _showAddGroupBottomSheet(context, controller, nameCtrl, placeCtrl);
              },
              borderRadius: BorderRadius.circular(30),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.4),
                      offset: Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group_add, size: 20, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      "Add Group",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() => controller.groups.isEmpty
          ? Center(
        child: Text(
          "No groups yet.\nStart by creating one!",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: controller.groups.length,
        itemBuilder: (c, i) {
          final g = controller.groups[i];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 6,
            shadowColor: Colors.teal.withOpacity(0.4),
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              title: Text(
                g['name'],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.3),
              ),
              subtitle: Text(
                "📍 ${g['place'] ?? ''}",
                style: TextStyle(color: Colors.grey[600]),
              ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showAddGroupBottomSheet(
                          context,
                          controller,
                          TextEditingController(text: g['name']),
                          TextEditingController(text: g['place']),
                          groupId: g['id'], // update mode
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteGroupDialog(context, controller, g); // <-- professional delete
                      },
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                onTap: () => Get.to(() => GroupDetailView(
                  group: g,
                  groupId: g['id'],    // Required
                  memberId: 0,         // No specific member yet
                  member: {},          // Empty map since no member is selected
                ))
            ),
          );
        },
      )),
    );
  }
}

void _showDeleteGroupDialog(BuildContext context, GroupController controller, Map group) {
  Get.defaultDialog(
    titlePadding: EdgeInsets.only(top: 16),
    title: "Delete Group",
    titleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    middleText: "",
    content: Column(
      children: [
        Icon(Icons.delete_forever, color: Colors.red.shade600, size: 50),
        SizedBox(height: 12),
        Text(
          "Are you sure you want to delete",
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        SizedBox(height: 4),
        Text(
          "${group['name']}?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
        ),
      ],
    ),
    barrierDismissible: true,
    backgroundColor: Colors.white,
    radius: 20,
    textCancel: "Cancel",
    cancelTextColor: Colors.grey[700],
    textConfirm: "Delete",
    confirmTextColor: Colors.white,
    onConfirm: () async {
      await controller.deleteGroup(group['id']);
      Get.back();
      Get.snackbar("Deleted", "${group['name']} has been removed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
          icon: Icon(Icons.check_circle, color: Colors.red.shade700));
    },
    buttonColor: Colors.red.shade600,
    cancel: null,
  );
}

// ---------------- MEMBER LIST -----------------
class MemberListView extends StatelessWidget {
  final int groupId;
  final Map group;
  MemberListView({required this.groupId, required this.group});

  final controller = Get.put(MemberController());
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final ThemeController themeController = Get.find<ThemeController>();


  @override
  Widget build(BuildContext context) {
    controller.loadMembers(groupId);

    return Scaffold(
      appBar: AppBar(
        title: Text("${group['name']} Members",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
      ),
      body: Obx(() => controller.members.isEmpty
          ? Center(
          child: Text(
            "No members yet.\nInvite someone to start!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ))
          : ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: controller.members.length,
        itemBuilder: (c, i) {
          final m = controller.members[i];
          return Card(
            elevation: 5,
            shadowColor: Colors.teal.withOpacity(0.3),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
            margin: EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.cyan.shade400,
                radius: 26,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              title: Text(
                m['name'],
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                m['phone'] ?? '',
                style: TextStyle(color: Colors.grey[700]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Edit dialog
                      _showAddMemberBottomSheet(
                        context,
                        controller,
                        groupId,
                        TextEditingController(text: m['name']),
                        TextEditingController(text: m['phone']),
                        memberId: m['id'], // update ke liye
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteMemberDialog(context, controller, groupId, m);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      )),
    );
  }
}

void _showDeleteMemberDialog(BuildContext context, MemberController controller, int groupId, Map member) {
  Get.defaultDialog(
    titlePadding: EdgeInsets.only(top: 16),
    title: "Delete Member",
    middleText: "",
    content: Column(
      children: [
        Icon(Icons.person_remove, color: Colors.red.shade600, size: 50),
        SizedBox(height: 12),
        Text(
          "Are you sure you want to delete",
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        SizedBox(height: 4),
        Text(
          "${member['name']}?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
        ),
      ],
    ),
    barrierDismissible: true,
    backgroundColor: Colors.white,
    radius: 20,
    textCancel: "Cancel",
    cancelTextColor: Colors.grey[700],
    textConfirm: "Delete",
    confirmTextColor: Colors.white,
    onConfirm: () async {
      await controller.deleteMember(groupId, member['id']);
      Get.back();
      Get.snackbar("Deleted", "${member['name']} has been removed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
          icon: Icon(Icons.check_circle, color: Colors.red.shade700));
    },
    buttonColor: Colors.red.shade600,
    cancel: null,
  );
}


// ---------------- GROUP DETAIL VIEW -----------------

class GroupDetailView extends StatelessWidget {
  final Map group;
  final int groupId;
  final int memberId;
  final Map member;

  final controller = Get.put(GroupDetailController());
  final memberController = Get.put(MemberController());
  final txnController = Get.put(TxnController());
  final ThemeController themeController = Get.find<ThemeController>();


  final amtCtrl = TextEditingController();
  final catCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  GroupDetailView({
    required this.group,
    required this.groupId,
    required this.memberId,
    required this.member,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Load group summary only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadGroupSummary(group['id']);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(group['name'], style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_outlined, size: 26),
            onPressed: () {
              _showAddMemberBottomSheet(
                context,
                memberController,
                group['id'],
                TextEditingController(),
                TextEditingController(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.list_alt_rounded, size: 26),
            onPressed: () {
              Get.to(() => MemberListView(groupId: group['id'], group: group));
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.memberSummaries.isEmpty) {
          return Center(
            child: Text(
              "No members or transactions yet",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                color: Colors.teal.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("💡 Settlement Summary",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 10),
                      ...controller.settlement.map((s) => Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${s['from']} ➝ ${s['to']}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("₹${s['amount'].toStringAsFixed(0)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade600,
                                    fontSize: 14)),
                          ],
                        ),
                      )),
                    ],
                  )),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.memberSummaries.length,
                padding: EdgeInsets.all(12),
                itemBuilder: (c, i) {
                  final m = controller.memberSummaries[i];
                  double balance = m['income'] - m['expense'];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    margin: EdgeInsets.symmetric(vertical: 6),
                    elevation: 5,
                    shadowColor: Colors.teal.withOpacity(0.3),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: balance >= 0 ? Colors.green : Colors.red,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(m['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "Income: ${formatRupees(m['income'])}  \nExpense: ${formatRupees(m['expense'])}"),
                      trailing: Text(
                        "Bal: ${formatRupees(balance)}",
                        style: TextStyle(
                            color: balance >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Get.to(() => TxnListView(
                          groupId: group['id'],
                          memberId: m['id'],
                          member: m,
                        ));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: InkWell(
        onTap: () async {
          await _showAddTxnBottomSheet(
            context,
            txnController,           // TxnController
            groupId,                 // groupId
            controller,   // GroupDetailController
            memberController,        // MemberController
            amtCtrl,                 // Amount TextEditingController
            catCtrl,                 // Category TextEditingController
            noteCtrl,                // Note TextEditingController
          );
        },
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade400, Colors.teal.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.5),
                offset: Offset(0, 6),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, size: 26, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Add Cash",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- TRANSACTION LIST -----------------
class TxnListView extends StatelessWidget {
  final int groupId;
  final int memberId;
  final Map member;

  TxnListView({required this.groupId, required this.memberId, required this.member});

  final controller = Get.put(TxnController());
  final amtCtrl = TextEditingController();
  final catCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final ThemeController themeController = Get.find<ThemeController>();


  @override
  Widget build(BuildContext context) {
    controller.loadTxns(memberId);

    return Scaffold(
      appBar: AppBar(
        title: Text("${member['name']} Transactions",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
      ),
      body: Column(
        children: [
          // 🔹 Summary Card
          Obx(() {
            double income = controller.totals['income'] ?? 0.0;
            double expense = controller.totals['expense'] ?? 0.0;
            double balance = income - expense;

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 6,
                shadowColor: Colors.teal.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Summary",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _summaryTile("Income", income, Colors.green),
                            _summaryTile("Expense", expense, Colors.red),
                            _summaryTile(
                                "Balance",
                                balance,
                                balance >= 0 ? Colors.green : Colors.red),
                          ],
                        ),
                      ]),
                ),
              ),
            );
          }),

          // 🔹 Transaction List
          Expanded(
            child: Obx(() => controller.txns.isEmpty
                ? Center(
                child: Text(
                  "No transactions yet.\nAdd your first transaction!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ))
                : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: controller.txns.length,
              itemBuilder: (c, i) {
                final t = controller.txns[i];
                bool isIncome = t['type'] == 'income';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 5,
                  shadowColor: Colors.teal.withOpacity(0.2),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor:
                      isIncome ? Colors.green : Colors.red,
                      child: Icon(
                        isIncome
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      "${t['category']} - ${formatRupees(t['amount'])}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      "${t['type']} | ${t['note'] ?? ''}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            amtCtrl.text = t['amount'].toString();
                            catCtrl.text = t['category'];
                            noteCtrl.text = t['note'] ?? '';

                            _showEditTxnBottomSheet(context, controller, t);
                          },
                        ),
                        // Delete button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteTxnDialog(context, controller, memberId, t);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),

    );
  }

  void _showDeleteTxnDialog(BuildContext context, TxnController controller, int memberId, Map txn) {
    Get.defaultDialog(
      titlePadding: EdgeInsets.only(top: 16),
      title: "Delete Transaction",
      middleText: "",
      content: Column(
        children: [
          Icon(Icons.delete_forever, color: Colors.red.shade600, size: 50),
          SizedBox(height: 12),
          Text(
            "Are you sure you want to delete this transaction?",
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            "${txn['category']} - ${txn['amount']}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade700),
          ),
        ],
      ),
      barrierDismissible: true,
      backgroundColor: Colors.white,
      radius: 20,
      textCancel: "Cancel",
      cancelTextColor: Colors.grey[700],
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await controller.deleteTxn(txn['id']);
        controller.loadTxns(memberId);
        Get.back();
        Get.snackbar("Deleted", "Transaction has been removed",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800,
            icon: Icon(Icons.check_circle, color: Colors.red.shade700));
      },
      buttonColor: Colors.red.shade600,
      cancel: null,
    );
  }

  Widget _summaryTile(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        SizedBox(height: 4),
        Text(formatRupees(amount),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  /// Bottom sheet for editing a transaction
  void _showEditTxnBottomSheet(
      BuildContext context,
      TxnController controller,
      Map txn,
      ) {
    final formKey = GlobalKey<FormState>();
    String type = txn['type'];

    Get.bottomSheet(
      SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 16,
              right: 16,
              top: 16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Edit Transaction",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: "Type",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  items: ["income", "expense"]
                      .map((e) => DropdownMenuItem(child: Text(e), value: e))
                      .toList(),
                  onChanged: (v) => type = v!,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: amtCtrl,
                  decoration: InputDecoration(
                    labelText: "Amount",
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Enter amount";
                    if (double.tryParse(v) == null || double.parse(v) <= 0)
                      return "Enter valid amount";
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: catCtrl,
                  decoration: InputDecoration(
                    labelText: "Category",
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? "Enter category" : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: "Note (optional)",
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade400),
                      onPressed: () => Get.back(),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await controller.updateTxn(
                            txn['id'],
                            type,
                            double.parse(amtCtrl.text),
                            catCtrl.text,
                            noteCtrl.text,
                          );
                          amtCtrl.clear();
                          catCtrl.clear();
                          noteCtrl.clear();
                          controller.loadTxns(memberId);
                          Get.back();
                        }
                      },
                      child: Text("Save", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
    );
  }
}
//
// ---------------- DIALOGS WITH VALIDATION ----------------
//


void _showAddGroupBottomSheet(
    BuildContext context,
    GroupController controller,
    TextEditingController nameCtrl,
    TextEditingController placeCtrl, {
      int? groupId,
    }) {
  final formKey = GlobalKey<FormState>();

  Get.bottomSheet(
    ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8), // glass effect
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Title with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups, color: Colors.teal, size: 26),
                    SizedBox(width: 8),
                    Text(
                      groupId == null ? "New Group" : "Edit Group",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // ✅ Group Name Field
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    hintText: "Enter group name",
                    prefixIcon: Icon(Icons.group, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Enter group name";
                    final words = v.trim().split(' ');
                    for (var word in words) {
                      if (word.isNotEmpty && word[0] != word[0].toUpperCase()) {
                        return "Each word must start with a capital letter";
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // ✅ Place Field
                TextFormField(
                  controller: placeCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    hintText: "Enter place",
                    prefixIcon: Icon(Icons.location_on, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Enter place";
                    final words = v.trim().split(' ');
                    for (var word in words) {
                      if (word.isNotEmpty && word[0] != word[0].toUpperCase()) {
                        return "Each word must start with a capital letter";
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // ✅ Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.close, color: Colors.redAccent),
                      label: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text("Save",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (groupId == null) {
                            controller.addGroup(nameCtrl.text, placeCtrl.text);
                          } else {
                            controller.updateGroup(groupId, nameCtrl.text, placeCtrl.text);
                          }
                          nameCtrl.clear();
                          placeCtrl.clear();
                          Get.back();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    backgroundColor: Colors.transparent, // ✅ glassmorphism
    isScrollControlled: true,
  );
}




void _showAddMemberBottomSheet(
    BuildContext context,
    MemberController controller,
    int groupId,
    TextEditingController nameCtrl,
    TextEditingController phoneCtrl, {
      int? memberId,
    }) {
  final formKey = GlobalKey<FormState>();

  Get.bottomSheet(
    ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, color: Colors.teal, size: 26),
                    SizedBox(width: 8),
                    Text(
                      memberId == null ? "Add Member" : "Edit Member",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    hintText: "Enter member name",
                    prefixIcon: Icon(Icons.person, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? "Enter member name" : null,
                ),
                SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    hintText: "Enter phone number",
                    prefixIcon: Icon(Icons.phone, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Enter phone number";
                    if (v.length != 10) return "Phone number must be 10 digits";
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.close, color: Colors.redAccent),
                      label: Text("Cancel", style: TextStyle(color: Colors.redAccent)),
                      onPressed: () => Get.back(),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text("Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (memberId == null) {
                            controller.addMember(groupId, nameCtrl.text, phoneCtrl.text);
                          } else {
                            controller.updateMember(groupId, memberId, nameCtrl.text, phoneCtrl.text);
                          }
                          nameCtrl.clear();
                          phoneCtrl.clear();
                          Get.back();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}

Future<void> _showAddTxnBottomSheet(
    BuildContext context,
    TxnController controller,
    int groupId,
    GroupDetailController groupDetailController,
    MemberController memberController,
    TextEditingController amtCtrl,
    TextEditingController catCtrl,
    TextEditingController noteCtrl,
    ) async {
  final formKey = GlobalKey<FormState>();
  String type = "income";
  int? selectedMemberId;

  // ✅ Members list refresh before showing bottom sheet
  await memberController.loadMembers(groupId);

  // ✅ Optionally select first member by default
  if (memberController.members.isNotEmpty) {
    selectedMemberId = memberController.members.first['id'];
  }

  await Get.bottomSheet(
    ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, color: Colors.teal, size: 26),
                    SizedBox(width: 8),
                    Text(
                      "New Transaction",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // --- Member selection ---
                Obx(() => DropdownButtonFormField<int>(
                  value: selectedMemberId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    labelText: "Select Member",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: memberController.members
                      .map((m) => DropdownMenuItem<int>(
                    value: m['id'],
                    child: Text(m['name']),
                  ))
                      .toList(),
                  validator: (v) =>
                  v == null ? "Select a member" : null,style: TextStyle(color: Colors.cyan),
                  onChanged: (v) => selectedMemberId = v,
                )),
                SizedBox(height: 16),

                // --- Type ---
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    labelText: "Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ["income", "expense"]
                      .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => type = v!,
                ),
                SizedBox(height: 16),

                // --- Amount ---
                TextFormField(
                  controller: amtCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    labelText: "Amount",
                    prefixIcon:
                    Icon(Icons.currency_rupee, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Enter amount";
                    }
                    if (double.tryParse(v) == null ||
                        double.parse(v) <= 0) {
                      return "Enter valid amount";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // --- Category ---
                TextFormField(
                  controller: catCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    labelText: "Category",
                    prefixIcon: Icon(Icons.category, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty
                      ? "Enter category"
                      : null,
                ),
                SizedBox(height: 16),

                // --- Note ---
                TextFormField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    labelText: "Note (optional)",
                    prefixIcon: Icon(Icons.note, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // --- Buttons ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.close, color: Colors.redAccent),
                      label: Text("Cancel",
                          style: TextStyle(color: Colors.redAccent)),
                      onPressed: () => Get.back(),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text("Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate() &&
                            selectedMemberId != null) {
                          await controller.addTxn(
                            groupId,
                            selectedMemberId!,
                            type,
                            double.parse(amtCtrl.text),
                            catCtrl.text,
                            noteCtrl.text,
                            DateTime.now().toIso8601String(),
                          );

                          amtCtrl.clear();
                          catCtrl.clear();
                          noteCtrl.clear();

                          await groupDetailController
                              .loadGroupSummary(groupId);
                          Get.back();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
  );
}







