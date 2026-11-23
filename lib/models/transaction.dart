import 'package:flutter/material.dart';

enum ExpenseCategory {
  food('Food', Icons.restaurant, Color(0xFFE8833A)),
  transport('Transport', Icons.directions_bus, Color(0xFF3A7BD5)),
  school('School', Icons.menu_book, Color(0xFF8E5CD9)),
  load('Load & Data', Icons.phone_android, Color(0xFF1AA6B7)),
  leisure('Leisure', Icons.sports_esports, Color(0xFFD9558B)),
  other('Other', Icons.category, Color(0xFF7A8A86));

  const ExpenseCategory(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

/// Plain data class. Member 2 can add toMap()/fromMap() for SQLite or Hive.
class AppTransaction {
  final int? id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final bool isIncome;

  const AppTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.isIncome = false,
  });

  AppTransaction copyWith({
    int? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    bool? isIncome,
  }) {
    return AppTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
