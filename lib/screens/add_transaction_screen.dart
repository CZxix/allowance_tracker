import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/transaction_store.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chip.dart';
import '../widgets/confirm_delete.dart';

/// Used for adding a new entry, or editing one when [existing] is given.
class AddTransactionScreen extends StatefulWidget {
  final AppTransaction? existing;
  const AddTransactionScreen({super.key, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _titleCtrl;
  late ExpenseCategory _category;
  late DateTime _date;
  late bool _isIncome;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amountCtrl = TextEditingController(
        text: e == null ? '' : e.amount.toStringAsFixed(2));
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _category = e?.category ?? ExpenseCategory.food;
    _date = e?.date ?? DateTime.now();
    _isIncome = e?.isIncome ?? false;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtrl.text.trim().isEmpty
        ? (_isIncome ? 'Income' : _category.label)
        : _titleCtrl.text.trim();

    final entry = AppTransaction(
      id: widget.existing?.id,
      title: title,
      amount: double.parse(_amountCtrl.text.trim()),
      category: _category,
      date: _date,
      isIncome: _isIncome,
    );

    final store = TransactionStore.instance;
    _editing ? store.update(entry) : store.add(entry);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_editing
          ? 'Changes saved'
          : (_isIncome ? 'Income added' : 'Expense added')),
    ));
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final e = widget.existing!;
    if (await confirmDelete(context, e.title) && mounted) {
      TransactionStore.instance.delete(e.id!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing
            ? 'Edit entry'
            : (_isIncome ? 'Add income' : 'Add expense')),
        actions: [
          if (_editing)
            IconButton(
              tooltip: 'Delete',
              icon: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Expense')),
                ButtonSegment(value: true, label: Text('Income')),
              ],
              selected: {_isIncome},
              onSelectionChanged: (s) => setState(() => _isIncome = s.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₱ ',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Enter an amount.';
                }
                final n = double.tryParse(v.trim());
                if (n == null) return 'Use numbers only, for example 85.50.';
                if (n <= 0) return 'Amount must be greater than zero.';
                if (n > 1000000) return 'Amount is too large.';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final c in ExpenseCategory.values)
                  CategoryChip(
                    category: c,
                    selected: c == _category,
                    onTap: () => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(DateFormat('MMMM d, y').format(_date)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleCtrl,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: 'Title (optional)',
                hintText: 'What was this for?',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_editing
                  ? 'Save changes'
                  : (_isIncome ? 'Save income' : 'Save expense')),
            ),
          ],
        ),
      ),
    );
  }
}
