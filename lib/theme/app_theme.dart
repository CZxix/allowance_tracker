import 'package:flutter/material.dart';

/// Material 3 theme. Every color comes from one seed color, so changing
/// [AppTheme.seed] re-themes the whole app (light and dark).
class AppTheme {
  static const Color seed = Color(0xFF00796B); // teal

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
}

/// Colors that Material's scheme doesn't provide (money gained).
class AppColors {
  static Color income(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF7FD6A8)
          : const Color(0xFF1E7A4F);
}
