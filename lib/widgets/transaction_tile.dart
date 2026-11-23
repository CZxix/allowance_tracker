import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final AppTransaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final scheme = Theme.of(context).colorScheme;
    final money = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    return Card.filled(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: CircleAvatar(
          backgroundColor: t.category.color.withOpacity(0.16),
          foregroundColor: t.category.color,
          child: Icon(t.category.icon, size: 22),
        ),
        title: Text(t.title),
        subtitle: Text(
            '${t.category.label} • ${DateFormat('MMM d').format(t.date)}'),
        trailing: Text(
          '${t.isIncome ? '+' : '-'}${money.format(t.amount)}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: t.isIncome ? AppColors.income(context) : scheme.error,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
