import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/txn.dart';
import '../utils/storage.dart';

class BankProvider extends ChangeNotifier {
  static const double openingBalance = 25000;

  List<Txn> txns = [];
  bool hideBalance = false;
  bool loaded = false;

  BankProvider() {
    _load();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _load() async {
    try {
      final m = await loadJson('bank');
      if (m != null) {
        txns = (m['txns'] as List).map((e) => Txn.fromJson(Map<String, dynamic>.from(e))).toList();
        hideBalance = m['hide'] ?? false;
      } else {
        txns = _seed();
      }
    } catch (_) {
      txns = _seed();
    }
    _sort();
    loaded = true;
    notifyListeners();
  }

  void _sort() => txns.sort((a, b) => b.date.compareTo(a.date));

  void _changed() {
    _sort();
    notifyListeners();
    saveJson('bank', {'txns': txns.map((t) => t.toJson()).toList(), 'hide': hideBalance});
  }

  List<Txn> _seed() {
    final now = DateTime.now();
    DateTime ago(int days, int hour) => DateTime(now.year, now.month, now.day, hour).subtract(Duration(days: days));
    int n = 0;
    Txn t(String title, Category c, double amt, bool income, DateTime d) =>
        Txn(id: 'seed${n++}', title: title, category: c, amount: amt, income: income, date: d);
    return [
      t('Salary - Nova Tech Pvt Ltd', Category.salary, 45000, true, DateTime(now.year, now.month, 1, 10)),
      t('Swiggy', Category.food, 450, false, ago(0, 13)),
      t('Amazon', Category.shopping, 2399, false, ago(1, 18)),
      t('Uber', Category.travel, 320, false, ago(1, 9)),
      t('Electricity Bill', Category.bills, 1850, false, ago(2, 11)),
      t('Netflix', Category.entertainment, 649, false, ago(3, 21)),
      t('Apollo Pharmacy', Category.health, 780, false, ago(4, 17)),
      t('Zomato', Category.food, 560, false, ago(5, 20)),
      t('Received from Rohan Mehta', Category.transfer, 3000, true, ago(5, 15)),
      t('Myntra', Category.shopping, 1799, false, ago(6, 16)),
      t('Metro Card Recharge', Category.travel, 500, false, ago(7, 8)),
      t('Cafe Coffee Day', Category.food, 240, false, ago(8, 12)),
      t('Movie Tickets', Category.entertainment, 600, false, ago(9, 19)),
    ];
  }

  // ---------- derived values ----------
  double get balance =>
      openingBalance + txns.fold(0.0, (s, t) => s + (t.income ? t.amount : -t.amount));

  bool _thisMonth(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month;
  }

  double get monthIncome =>
      txns.where((t) => t.income && _thisMonth(t.date)).fold(0.0, (s, t) => s + t.amount);

  double get monthExpense =>
      txns.where((t) => !t.income && _thisMonth(t.date)).fold(0.0, (s, t) => s + t.amount);

  Map<Category, double> get spendByCategory {
    final map = <Category, double>{};
    for (final t in txns) {
      if (!t.income && _thisMonth(t.date)) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  /// Spending for the last 7 days; index 6 is today.
  List<double> get last7Days {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = List<double>.filled(7, 0);
    for (final t in txns) {
      if (t.income) continue;
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      final diff = today.difference(d).inDays;
      if (diff >= 0 && diff < 7) out[6 - diff] += t.amount;
    }
    return out;
  }

  // ---------- actions ----------
  void toggleHide() {
    hideBalance = !hideBalance;
    _changed();
  }

  void addTxn({
    required String title,
    required Category category,
    required double amount,
    required bool income,
    String note = '',
  }) {
    txns.add(Txn(
      id: _id(),
      title: title,
      category: category,
      amount: amount,
      income: income,
      date: DateTime.now(),
      note: note,
    ));
    _changed();
  }

  void reset() {
    txns = _seed();
    hideBalance = false;
    _changed();
  }
}
