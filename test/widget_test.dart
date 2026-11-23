import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:allowance_tracker/main.dart';
import 'package:allowance_tracker/screens/add_transaction_screen.dart';

void main() {
  testWidgets('App opens on the Home screen', (tester) async {
    await tester.pumpWidget(const AllowanceTrackerApp());
    expect(find.text('My allowance'), findsWidgets);
    expect(find.text('Left to spend'), findsOneWidget);
  });

  testWidgets('Add screen shows an error when the amount is empty',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddTransactionScreen()));
    await tester.ensureVisible(find.text('Save expense'));
    await tester.tap(find.text('Save expense'));
    await tester.pump();
    expect(find.text('Enter an amount.'), findsOneWidget);
  });

  testWidgets('Add screen rejects zero', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddTransactionScreen()));
    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.ensureVisible(find.text('Save expense'));
    await tester.tap(find.text('Save expense'));
    await tester.pump();
    expect(find.text('Amount must be greater than zero.'), findsOneWidget);
  });
}
