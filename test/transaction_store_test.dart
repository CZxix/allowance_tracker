import 'package:flutter_test/flutter_test.dart';
import 'package:allowance_tracker/data/transaction_store.dart';
import 'package:allowance_tracker/models/transaction.dart';

void main() {
  final store = TransactionStore.instance;

  setUp(store.resetToSample);

  AppTransaction expense(double amount) => AppTransaction(
        title: 'Test',
        amount: amount,
        category: ExpenseCategory.food,
        date: DateTime.now(),
      );

  test('starting balance matches sample data', () {
    expect(store.remaining, closeTo(2556, 0.001));
  });

  test('adding an expense lowers the balance', () {
    store.add(expense(100));
    expect(store.remaining, closeTo(2456, 0.001));
  });

  test('adding income raises the balance', () {
    store.add(AppTransaction(
      title: 'Allowance',
      amount: 500,
      category: ExpenseCategory.other,
      date: DateTime.now(),
      isIncome: true,
    ));
    expect(store.remaining, closeTo(3056, 0.001));
  });

  test('editing an expense updates the balance', () {
    store.add(expense(100));
    final saved = store.items.firstWhere((t) => t.title == 'Test');
    store.update(saved.copyWith(amount: 50));
    expect(store.remaining, closeTo(2506, 0.001));
  });

  test('deleting an expense restores the balance', () {
    store.add(expense(100));
    final saved = store.items.firstWhere((t) => t.title == 'Test');
    store.delete(saved.id!);
    expect(store.remaining, closeTo(2556, 0.001));
  });

  test('category limit can be set and removed', () {
    store.setLimit(ExpenseCategory.food, 500);
    expect(store.limits[ExpenseCategory.food], 500);
    store.setLimit(ExpenseCategory.food, null);
    expect(store.limits.containsKey(ExpenseCategory.food), false);
  });

  test('clearAll removes everything', () {
    store.clearAll();
    expect(store.items, isEmpty);
    expect(store.remaining, 0);
  });
}
