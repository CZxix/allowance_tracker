import 'package:flutter/material.dart';
import '../data/transaction_store.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TransactionStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final recent = store.items.take(5).toList();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('My allowance')),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: BalanceCard(
                    allowance: store.totalIncome,
                    spent: store.totalSpent,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
                sliver: SliverToBoxAdapter(
                  child: Text('Recent activity',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              if (recent.isEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 240,
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message:
                          'No entries yet. Tap Add to record your first one.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, 96),
                  sliver: SliverList.separated(
                    itemCount: recent.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) => TransactionTile(
                      transaction: recent[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AddTransactionScreen(existing: recent[i]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
