import 'package:flutter/material.dart';

enum Category { food, shopping, travel, bills, entertainment, health, salary, transfer }

extension CategoryX on Category {
  String get label => switch (this) {
        Category.food => 'Food',
        Category.shopping => 'Shopping',
        Category.travel => 'Travel',
        Category.bills => 'Bills',
        Category.entertainment => 'Entertainment',
        Category.health => 'Health',
        Category.salary => 'Salary',
        Category.transfer => 'Transfer',
      };

  IconData get icon => switch (this) {
        Category.food => Icons.restaurant,
        Category.shopping => Icons.shopping_bag,
        Category.travel => Icons.directions_car,
        Category.bills => Icons.receipt,
        Category.entertainment => Icons.movie,
        Category.health => Icons.local_hospital,
        Category.salary => Icons.account_balance_wallet,
        Category.transfer => Icons.swap_horiz,
      };

  Color get color => switch (this) {
        Category.food => const Color(0xFFFB8C00),
        Category.shopping => const Color(0xFF8E24AA),
        Category.travel => const Color(0xFF00897B),
        Category.bills => const Color(0xFFE53935),
        Category.entertainment => const Color(0xFFD81B60),
        Category.health => const Color(0xFF43A047),
        Category.salary => const Color(0xFF2E7D32),
        Category.transfer => const Color(0xFF1E88E5),
      };
}

class Txn {
  final String id;
  final String title;
  final Category category;
  final double amount; // always positive
  final bool income;
  final DateTime date;
  final String note;

  const Txn({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.income,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'amount': amount,
        'income': income,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Txn.fromJson(Map<String, dynamic> j) => Txn(
        id: j['id'],
        title: j['title'],
        category: Category.values.byName(j['category']),
        amount: (j['amount'] as num).toDouble(),
        income: j['income'],
        date: DateTime.parse(j['date']),
        note: j['note'] ?? '',
      );
}
