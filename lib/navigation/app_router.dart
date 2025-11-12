// Файл: lib/navigation/app_router.dart

import 'package:bloom/main.dart';
import 'package:bloom/screens/onboarding_screen.dart';
import 'package:bloom/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:bloom/screens/auth_gate.dart';
import 'package:bloom/screens/auth_screen.dart';
import 'package:bloom/themes/app_themes.dart';

class AppRouter {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String settings = '/settings';
  static const String auth = '/auth';
  static const String authGate = '/authGate';

  static Route<dynamic> generateRoute(
      RouteSettings routeSettings, {
        required Function(Locale) onLocaleChanged,
        required Function(AppTheme) onThemeChanged,
      }) {
    final Map<String, dynamic>? args = routeSettings.arguments as Map<String, dynamic>?;

    switch (routeSettings.name) {
      case authGate:
        return MaterialPageRoute(
          builder: (_) => const AuthGate(),
          settings: routeSettings,
        );
      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(),
          settings: routeSettings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            onLocaleChanged: onLocaleChanged,
            onThemeChanged: onThemeChanged,
          ),
          settings: routeSettings,
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            onLocaleChanged: onLocaleChanged,
          ),
          settings: routeSettings,
        );
      case settings:
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(
            onLanguageChanged: args?['onLanguageChanged'] ?? onLocaleChanged,
            onThemeChanged: args?['onThemeChanged'] ?? onThemeChanged,
          ),
          settings: routeSettings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const AuthGate(),
          settings: routeSettings,
        );
    }
  }
}