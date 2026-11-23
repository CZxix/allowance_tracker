import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// Remaining allowance in a tonal container.
/// Progress turns red and a message appears near or over the limit.
class BalanceCard extends StatelessWidget {
  final double allowance;
  final double spent;

  const BalanceCard({super.key, required this.allowance, required this.spent});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final money = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

    final remaining = allowance - spent;
    final ratio = allowance <= 0 ? 0.0 : (spent / allowance).clamp(0.0, 1.0);
    final over = spent > allowance;
    final near = !over && ratio >= 0.85;

    return Card.filled(
      margin: EdgeInsets.zero,
      color: scheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Left to spend',
                style: text.titleMedium
                    ?.copyWith(color: scheme.onPrimaryContainer)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              money.format(remaining),
              style: text.displaySmall?.copyWith(
                color: over ? scheme.error : scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: over ? scheme.error : scheme.primary,
              backgroundColor: scheme.onPrimaryContainer.withOpacity(0.15),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spent ${money.format(spent)}',
                    style: text.bodyMedium
                        ?.copyWith(color: scheme.onPrimaryContainer)),
                Text('of ${money.format(allowance)}',
                    style: text.bodyMedium
                        ?.copyWith(color: scheme.onPrimaryContainer)),
              ],
            ),
            if (over || near) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: over
                      ? scheme.errorContainer
                      : scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: over
                          ? scheme.onErrorContainer
                          : scheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        over
                            ? 'You are over your allowance.'
                            : 'You have used over 85% of your allowance.',
                        style: text.labelLarge?.copyWith(
                          color: over
                              ? scheme.onErrorContainer
                              : scheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
