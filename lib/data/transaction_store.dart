import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import 'dummy_data.dart';

/// App-wide state. Screens listen to this and rebuild when data changes.
///
/// MEMBER 2: replace the list/map operations below with SQLite/Hive calls.
/// Keep the method names and getters and no screen needs to change.
/// Call notifyListeners() after every change.
class TransactionStore extends ChangeNotifier {
  TransactionStore._();
  static final TransactionStore instance = TransactionStore._();

  final List<AppTransaction> _items = DummyData.seed;
  final Map<ExpenseCategory, double> _limits = {};
  int _nextId = 100;

  /// Newest first.
  List<AppTransaction> get items {
    final copy = [..._items];
    copy.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : (b.id ?? 0).compareTo(a.id ?? 0);
    });
    return copy;
  }

  /// All money added (allowance + other income). This is the budget.
  double get totalIncome =>
      _items.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get totalSpent =>
      _items.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get remaining => totalIncome - totalSpent;

  /// Expenses on or after [since] (all expenses when null).
  List<AppTransaction> expensesSince(DateTime? since) => _items
      .where((t) => !t.isIncome && (since == null || !t.date.isBefore(since)))
      .toList();

  double spentIn(ExpenseCategory category, {DateTime? since}) =>
      expensesSince(since)
          .where((t) => t.category == category)
          .fold(0.0, (s, t) => s + t.amount);

  // ---- Monthly category limits -------------------------------------------

  Map<ExpenseCategory, double> get limits => Map.unmodifiable(_limits);

  /// Pass null (or 0 or less) to remove the limit.
  void setLimit(ExpenseCategory category, double? value) {
    if (value == null || value <= 0) {
      _limits.remove(category);
    } else {
      _limits[category] = value;
    }
    notifyListeners();
  }

  // ---- Add / edit / delete -----------------------------------------------

  void add(AppTransaction t) {
    _items.add(t.copyWith(id: _nextId++));
    notifyListeners();
  }

  void update(AppTransaction t) {
    final i = _items.indexWhere((x) => x.id == t.id);
    if (i == -1) return;
    _items[i] = t;
    notifyListeners();
  }

  void delete(int id) {
    _items.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Puts a deleted item back (used by Undo).
  void restore(AppTransaction t) {
    _items.add(t);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    _limits.clear();
    notifyListeners();
  }

  void resetToSample() {
    _items
      ..clear()
      ..addAll(DummyData.seed);
    _limits.clear();
    notifyListeners();
  }
}
