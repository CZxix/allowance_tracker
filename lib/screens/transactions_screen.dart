import 'package:flutter/material.dart';
import '../data/transaction_store.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_delete.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _store = TransactionStore.instance;
  String _query = '';
  ExpenseCategory? _category; // null = all categories

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final all = _store.items;
        final q = _query.trim().toLowerCase();
        final items = all.where((t) {
          final matchesText = q.isEmpty ||
              t.title.toLowerCase().contains(q) ||
              t.category.label.toLowerCase().contains(q);
          final matchesCategory = _category == null || t.category == _category;
          return matchesText && matchesCategory;
        }).toList();
        final scheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('History')),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: SearchBar(
                    hintText: 'Search entries',
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                      for (final c in ExpenseCategory.values) ...[
                        const SizedBox(width: AppSpacing.sm),
                        FilterChip(
                          avatar: Icon(c.icon, size: 18, color: c.color),
                          label: Text(c.label),
                          selected: _category == c,
                          onSelected: (_) => setState(
                              () => _category = _category == c ? null : c),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: all.isEmpty
                        ? Icons.receipt_long_outlined
                        : Icons.search_off,
                    message: all.isEmpty
                        ? 'Nothing here yet. Tap Add to record an expense or income.'
                        : 'No entries match your search or filter.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.sm, AppSpacing.md, 96),
                  sliver: SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final t = items[i];
                      return Dismissible(
                        key: ValueKey(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding:
                              const EdgeInsets.only(right: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.delete_outline,
                              color: scheme.onErrorContainer),
                        ),
                        confirmDismiss: (_) => confirmDelete(context, t.title),
                        onDismissed: (_) {
                          _store.delete(t.id!);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: const Text('Entry deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () => _store.restore(t),
                              ),
                            ));
                        },
                        child: TransactionTile(
                          transaction: t,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddTransactionScreen(existing: t),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
