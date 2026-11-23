import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/transaction_store.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _store = TransactionStore.instance;
  final _formKey = GlobalKey<FormState>();
  final _allowanceCtrl = TextEditingController();

  @override
  void dispose() {
    _allowanceCtrl.dispose();
    super.dispose();
  }

  void _addAllowance() {
    if (!_formKey.currentState!.validate()) return;
    _store.add(AppTransaction(
      title: 'Allowance',
      amount: double.parse(_allowanceCtrl.text.trim()),
      category: ExpenseCategory.other,
      date: DateTime.now(),
      isIncome: true,
    ));
    _allowanceCtrl.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Allowance added')));
  }

  Future<void> _editLimit(ExpenseCategory c, double? current) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => _LimitDialog(category: c, current: current),
    );
    if (result == null) return;
    _store.setLimit(c, result < 0 ? null : result);
  }

  Future<void> _confirm({
    required String title,
    required String message,
    required String action,
    required VoidCallback onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(action)),
        ],
      ),
    );
    if (ok == true) onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final money = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('Settings')),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, 96),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text('Add allowance', style: text.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Record money you received. It is added to your balance.',
                      style: text.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Form(
                      key: _formKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _allowanceCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                prefixText: '₱ ',
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter an amount.';
                                }
                                final n = double.tryParse(v.trim());
                                if (n == null) return 'Use numbers only.';
                                if (n <= 0) return 'Must be more than zero.';
                                if (n > 1000000) return 'Amount is too large.';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: FilledButton(
                              onPressed: _addAllowance,
                              child: const Text('Add'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Monthly category limits', style: text.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Set a limit to see how much of it you have used this month.',
                      style: text.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final c in ExpenseCategory.values)
                      _limitTile(context, c, monthStart, money),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Data', style: text.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Card.filled(
                      margin: EdgeInsets.zero,
                      color: scheme.surfaceContainerLow,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.restore),
                            title: const Text('Restore sample data'),
                            onTap: () => _confirm(
                              title: 'Restore sample data?',
                              message:
                                  'This replaces all entries with the sample entries.',
                              action: 'Restore',
                              onConfirm: _store.resetToSample,
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.delete_sweep_outlined,
                                color: scheme.error),
                            title: Text('Clear all entries',
                                style: TextStyle(color: scheme.error)),
                            onTap: () => _confirm(
                              title: 'Clear all entries?',
                              message:
                                  'All entries and limits will be removed. This cannot be undone.',
                              action: 'Clear all',
                              onConfirm: _store.clearAll,
                            ),
                          ),
                        ],
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

  Widget _limitTile(BuildContext context, ExpenseCategory c,
      DateTime monthStart, NumberFormat money) {
    final scheme = Theme.of(context).colorScheme;
    final limit = _store.limits[c];
    final spent = _store.spentIn(c, since: monthStart);
    final over = limit != null && spent > limit;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card.filled(
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () => _editLimit(c, limit),
          leading: CircleAvatar(
            backgroundColor: c.color.withOpacity(0.16),
            foregroundColor: c.color,
            child: Icon(c.icon, size: 22),
          ),
          title: Text(c.label),
          subtitle: limit == null
              ? const Text('No limit set')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${money.format(spent)} of ${money.format(limit)}'
                      '${over ? ' • over limit' : ''}',
                      style: TextStyle(color: over ? scheme.error : null),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: (spent / limit).clamp(0.0, 1.0),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(6),
                      color: over ? scheme.error : c.color,
                    ),
                  ],
                ),
          trailing: const Icon(Icons.edit_outlined),
        ),
      ),
    );
  }
}

/// Pops a positive number to set the limit, -1 to remove it, null to cancel.
class _LimitDialog extends StatefulWidget {
  final ExpenseCategory category;
  final double? current;
  const _LimitDialog({required this.category, required this.current});

  @override
  State<_LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends State<_LimitDialog> {
  late final TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.current == null ? '' : widget.current!.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final n = double.tryParse(_ctrl.text.trim());
    if (n == null || n <= 0) {
      setState(() => _error = 'Enter an amount greater than zero.');
    } else if (n > 1000000) {
      setState(() => _error = 'Amount is too large.');
    } else {
      Navigator.pop(context, n);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.category.label} limit'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Monthly limit',
          prefixText: '₱ ',
          errorText: _error,
        ),
      ),
      actions: [
        if (widget.current != null)
          TextButton(
            onPressed: () => Navigator.pop(context, -1.0),
            child: const Text('Remove limit'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
