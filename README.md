# Allowance Tracker

A Flutter app that helps students track their allowance and daily expenses.

## Features
1. Add, edit and delete expenses and income
2. Live "Left to spend" balance with near-limit and over-budget warnings
3. History with search and category filter, swipe to delete with undo
4. Reports: spending by category (donut chart) for week, month or all time
5. Settings: add allowance, monthly category limits, restore or clear data
6. Input validation with clear error messages
7. Light and dark theme (Material 3)

## Screens
Home, History, Add/Edit entry, Reports, Settings

## Run
```
flutter pub get
flutter run
```
Run the tests with `flutter test`.

## Project structure
- `lib/theme`    Material 3 theme and spacing
- `lib/models`   `AppTransaction` and `ExpenseCategory`
- `lib/data`     `TransactionStore` (app state) and sample data
- `lib/widgets`  reusable widgets: BalanceCard, TransactionTile, CategoryChip, EmptyState, confirm dialog
- `lib/screens`  one file per screen
- `test`         widget and unit tests
- `docs`         test cases

## Note for Member 2 (data storage)
Data is currently kept in memory and resets when the app restarts.
All data access goes through `lib/data/transaction_store.dart`.
To add SQLite or Hive:
1. Add `toMap()` / `fromMap()` to `AppTransaction` (`lib/models/transaction.dart`).
2. Replace the list and map operations in `TransactionStore` with database calls.
   Keep the method names (`add`, `update`, `delete`, `restore`, `clearAll`,
   `resetToSample`, `setLimit`) and getters, and call `notifyListeners()` after each change.
   The screens do not need to change.
3. Persist the category limits too.

## Disclosure
- Package used: `intl`
- This project was developed with help from AI (Claude by Anthropic).
++