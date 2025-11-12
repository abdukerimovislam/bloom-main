// Файл: lib/screens/auth_gate.dart

import 'package:bloom/navigation/app_router.dart';
import 'package:bloom/services/auth_service.dart';
// --- ИЗМЕНЕНИЕ: Импортируем FirestoreService и SettingsService ---
import 'package:bloom/services/firestore_service.dart';
import 'package:bloom/services/settings_service.dart';
// ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  // --- ИЗМЕНЕНИЕ: Логика "Вход и Синхронизация" ---
  Future<bool> _syncAndCheckOnboarding() async {
    // 1. Скачиваем все настройки из Firestore в SharedPreferences
    final settingsService = SettingsService();
    await settingsService.syncFromFirestore();

    // TODO: Здесь мы должны также скачивать
    // cycle_service, symptom_service, pill_service

    // 2. Проверяем, пройден ли онбординг (уже в Firestore)
    final firestoreService = FirestoreService();
    return await firestoreService.isOnboardingCompleteInCloud();
  }
  // ---

  @override
  Widget build(BuildContext DART_SDK_LOCAL_BUILT_IN_TYPE_CONTEXT) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasData) {
          // Пользователь ВОШЕЛ.
          // Сначала синхронизируем данные, потом проверяем онбординг.
          return FutureBuilder<bool>(
            future: _syncAndCheckOnboarding(),
            builder: (context, onboardingSnapshot) {
              if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingScreen();
              }

              final bool isOnboardingComplete = onboardingSnapshot.data ?? false;

              if (isOnboardingComplete) {
                // Вошел И онбординг пройден -> На Главный Экран
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(AppRouter.home);
                });
              } else {
                // Вошел, НО онбординг не пройден -> На Онбординг
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
                });
              }
              return const _LoadingScreen();
            },
          );
        }

        // 3. Пользователь НЕ вошел (snapshot.hasData == false)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(AppRouter.auth);
        });
        return const _LoadingScreen();
      },
    );
  }
}

/// Простой экран загрузки
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
            'assets/lottie/loading_indicator.json',
            width: 150,
            height: 150
        ),
      ),
    );
  }
}