import 'package:flutter/material.dart';
import '../models/transaction.dart';

class CategoryChip extends StatelessWidget {
  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(category.icon,
          size: 18, color: selected ? Colors.white : category.color),
      label: Text(category.label),
      selected: selected,
      selectedColor: category.color,
      showCheckmark: false,
      labelStyle: TextStyle(color: selected ? Colors.white : null),
      onSelected: (_) => onTap(),
    );
  }
}
