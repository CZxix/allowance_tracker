import 'package:flutter/material.dart';
import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

void main() => runApp(const AllowanceTrackerApp());

class AllowanceTrackerApp extends StatelessWidget {
  const AllowanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allowance Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // follows the phone's light/dark setting
      home: const AppShell(),
    );
  }
}
