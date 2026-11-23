import '../models/transaction.dart';

/// Starting data only. The app reads/writes through TransactionStore.
class DummyData {
  static List<AppTransaction> get seed => [
        AppTransaction(
            id: 1,
            title: 'Lunch at canteen',
            amount: 85,
            category: ExpenseCategory.food,
            date: DateTime.now()),
        AppTransaction(
            id: 2,
            title: 'Jeepney fare',
            amount: 30,
            category: ExpenseCategory.transport,
            date: DateTime.now()),
        AppTransaction(
            id: 3,
            title: 'Printing project',
            amount: 120,
            category: ExpenseCategory.school,
            date: DateTime.now().subtract(const Duration(days: 1))),
        AppTransaction(
            id: 4,
            title: 'Weekly allowance',
            amount: 3000,
            category: ExpenseCategory.other,
            date: DateTime.now().subtract(const Duration(days: 3)),
            isIncome: true),
        AppTransaction(
            id: 5,
            title: 'Mobile data',
            amount: 99,
            category: ExpenseCategory.load,
            date: DateTime.now().subtract(const Duration(days: 2))),
        AppTransaction(
            id: 6,
            title: 'Milk tea',
            amount: 110,
            category: ExpenseCategory.leisure,
            date: DateTime.now().subtract(const Duration(days: 2))),
      ];
}
