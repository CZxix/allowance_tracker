import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/transaction_store.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

enum ReportPeriod { week, month, all }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _store = TransactionStore.instance;
  ReportPeriod _period = ReportPeriod.week;

  DateTime? get _start {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case ReportPeriod.week:
        return today.subtract(Duration(days: now.weekday - 1));
      case ReportPeriod.month:
        return DateTime(now.year, now.month, 1);
      case ReportPeriod.all:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final text = Theme.of(context).textTheme;
        final money = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

        final totals = <ExpenseCategory, double>{};
        for (final t in _store.expensesSince(_start)) {
          totals[t.category] = (totals[t.category] ?? 0) + t.amount;
        }
        final entries = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final total = entries.fold(0.0, (s, e) => s + e.value);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('Reports')),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: SegmentedButton<ReportPeriod>(
                    segments: const [
                      ButtonSegment(
                          value: ReportPeriod.week, label: Text('This week')),
                      ButtonSegment(
                          value: ReportPeriod.month,
                          label: Text('This month')),
                      ButtonSegment(
                          value: ReportPeriod.all, label: Text('All time')),
                    ],
                    selected: {_period},
                    onSelectionChanged: (s) =>
                        setState(() => _period = s.first),
                  ),
                ),
              ),
              if (entries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.pie_chart_outline,
                    message: 'No spending in this period yet.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.lg, AppSpacing.md, 96),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Center(
                        child: SizedBox(
                          width: 210,
                          height: 210,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(210, 210),
                                painter: _DonutPainter(
                                  entries: entries,
                                  total: total,
                                  trackColor: scheme.surfaceContainerHighest,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Spent', style: text.labelLarge),
                                  Text(money.format(total),
                                      style: text.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Card.filled(
                        margin: EdgeInsets.zero,
                        color: scheme.secondaryContainer,
                        child: ListTile(
                          leading: Icon(entries.first.key.icon,
                              color: scheme.onSecondaryContainer),
                          title: Text('Biggest spending',
                              style: TextStyle(
                                  color: scheme.onSecondaryContainer)),
                          subtitle: Text(
                            '${entries.first.key.label} • ${money.format(entries.first.value)}',
                            style: TextStyle(
                                color: scheme.onSecondaryContainer),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('By category', style: text.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      for (final e in entries)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _CategoryRow(
                            category: e.key,
                            amount: e.value,
                            total: total,
                          ),
                        ),
                    ]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final ExpenseCategory category;
  final double amount;
  final double total;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final money = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final share = total == 0 ? 0.0 : amount / total;

    return Column(
      children: [
        Row(
          children: [
            Icon(category.icon, color: category.color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(category.label, style: text.bodyLarge)),
            Text('${(share * 100).round()}%', style: text.bodyMedium),
            const SizedBox(width: AppSpacing.md),
            Text(money.format(amount),
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: share,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
          color: category.color,
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<ExpenseCategory, double>> entries;
  final double total;
  final Color trackColor;

  _DonutPainter({
    required this.entries,
    required this.total,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 28.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = trackColor);
    if (total <= 0) return;

    var start = -math.pi / 2;
    for (final e in entries) {
      final sweep = (e.value / total) * math.pi * 2;
      canvas.drawArc(rect, start, sweep, false, paint..color = e.key.color);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}
