// Файл: lib/navigation/app_router.dart

import 'package:bloom/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:bloom/themes/app_themes.dart';

// --- ИЗМЕНЕНИЕ: Добавляем импорт для PillInfoScreen ---
import 'package:bloom/screens/pill_info_screen.dart';
// ---

class AppRouter {
  // --- ИЗМЕНЕНИЕ: Оставляем только "внутренние" роуты ---
  static const String settings = '/settings';

  // --- ИЗМЕНЕНИЕ: Добавляем роут pillInfo ---
  static const String pillInfo = '/pill-info';
  // ---

  static Route<dynamic> generateRoute(
      RouteSettings routeSettings, {
        required Function(Locale) onLocaleChanged,
        required Function(AppTheme) onThemeChanged,
        required VoidCallback onSignOut,
      }) {

    switch (routeSettings.name) {

      case settings:
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(
            onLanguageChanged: onLocaleChanged,
            onThemeChanged: onThemeChanged,
            onSignOut: onSignOut,
          ),
          settings: routeSettings,
        );

    // --- ИЗМЕНЕНИЕ: Добавляем case для pillInfo ---
      case pillInfo:
        return MaterialPageRoute(
          builder: (_) => const PillInfoScreen(),
        );
    // ---

      default:
      // Возвращаем ошибку, если роут не найден
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text("Ошибка")),
            body: const Center(
              child: Text('Роут не найден'),
            ),
          ),
          settings: routeSettings,
        );
    }
  }
}