
import 'package:app/import_export.dart';

/// ---------------- GROUP CONTROLLER ----------------
class GroupController extends GetxController {
  var groups = [].obs;
  final db = DBHelper();

  Future<void> loadGroups() async {
    groups.value = await db.fetchGroups();
  }

  Future<void> addGroup(String name, String place) async {
    await db.insertGroup({'name': name, 'place': place});
    await loadGroups();
  }

  Future<void> updateGroup(int id, String name, String place) async {
    await db.updateGroup(id, {'name': name, 'place': place});
    await loadGroups();
  }

  Future<void> deleteGroup(int id) async {
    await db.deleteGroup(id);
    await loadGroups();
  }
}


/// ---------------- MEMBER CONTROLLER ----------------
class MemberController extends GetxController {
  var members = [].obs;
  final db = DBHelper();

  Future<void> loadMembers(int groupId) async {
    members.value = await db.fetchMembers(groupId);
  }

  Future<void> addMember(int groupId, String name, String phone) async {
    await db.insertMember({'group_id': groupId, 'name': name, 'phone': phone});
    loadMembers(groupId);
  }

  Future<void> updateMember(int groupId, int memberId, String name, String phone) async {
    await db.updateMember(memberId, {'name': name, 'phone': phone});
    loadMembers(groupId);
  }

  Future<void> deleteMember(int groupId, int memberId) async {
    await db.deleteMember(memberId);
    loadMembers(groupId);
  }
}

/// ---------------- TRANSACTION CONTROLLER ----------------
class TxnController extends GetxController {
  var txns = <Map<String, dynamic>>[].obs;
  var totals = {"income": 0.0, "expense": 0.0}.obs;
  final db = DBHelper();

  Future<void> loadTxns(int memberId) async {
    txns.value = await db.fetchMemberTxns(memberId);
    totals.value = await db.memberTotals(memberId);
  }

  Future<void> addTxn(
      int groupId,
      int? memberId,
      String type,
      double amount,
      String category,
      String note,
      String date,
      ) async {
    await db.insertTxn({
      'group_id': groupId,
      'member_id': memberId,
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date,
    });

    // Agar memberId null hai → to group ke liye reload karo
    if (memberId != null) {
      await loadTxns(memberId);
    }
  }


  Future<void> updateTxn(
      int txnId,
      String type,
      double amount,
      String category,
      String note,
      ) async {
    await db.updateTxn(txnId, {
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
    });
    // Refresh transactions and totals for the member
    var txn = txns.firstWhere((t) => t['id'] == txnId);
    await loadTxns(txn['member_id']);
  }

  Future<void> deleteTxn(int txnId) async {
    var txn = txns.firstWhere((t) => t['id'] == txnId);
    await db.deleteTxn(txnId);
    await loadTxns(txn['member_id']);
  }
}

/// ---------------- GROUP DETAIL CONTROLLER ----------------

class GroupDetailController extends GetxController {
  final DBHelper db = DBHelper();

  var memberSummaries = <Map<String, dynamic>>[].obs; // {id, name, income, expense, balance}
  var settlement = <Map<String, dynamic>>[].obs; // {from, to, amount}

  /// Load members and transactions for the group
  Future<void> loadGroupSummary(int groupId) async {
    final members = await db.fetchMembers(groupId);

    List<Map<String, dynamic>> summaries = [];

    for (var m in members) {
      final txns = await db.fetchMemberTxns(m['id']);
      double income = 0.0;
      double expense = 0.0;

      for (var t in txns) {
        if (t['type'] == 'income') {
          income += (t['amount'] ?? 0.0);
        } else if (t['type'] == 'expense') {
          expense += (t['amount'] ?? 0.0);
        }
      }

      summaries.add({
        'id': m['id'],
        'name': m['name'],
        'income': income,
        'expense': expense,
        'balance': income - expense,
      });
    }

    memberSummaries.assignAll(summaries);

    // Calculate settlement summary
    _calculateSettlement();
  }

  void _calculateSettlement() {
    List<Map<String, dynamic>> givers = [];
    List<Map<String, dynamic>> takers = [];

    for (var m in memberSummaries) {
      double bal = m['balance'];
      if (bal < 0) {
        givers.add({'name': m['name'], 'amount': -bal});
      } else if (bal > 0) {
        takers.add({'name': m['name'], 'amount': bal});
      }
    }

    // Optional: sort descending
    givers.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    takers.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    List<Map<String, dynamic>> result = [];

    for (var g in givers) {
      double giveAmt = g['amount'];
      for (var t in takers) {
        if (giveAmt <= 0) break;
        if (t['amount'] <= 0) continue;

        double settledAmt = giveAmt < t['amount'] ? giveAmt : t['amount'];

        result.add({
          'from': g['name'],
          'to': t['name'],
          'amount': settledAmt,
        });

        giveAmt -= settledAmt;
        t['amount'] -= settledAmt;
      }
    }

    settlement.assignAll(result);
  }
}