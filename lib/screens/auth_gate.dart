import 'dart:async';
import 'package:bloom/services/auth_service.dart';
import 'package:bloom/services/firestore_service.dart';
import 'package:bloom/services/sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:bloom/navigation/app_router.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    Future.microtask(_handleAuthFlow);
  }

  Future<void> _handleAuthFlow() async {
    try {
      /// 1) Сначала пробуем быстрый вариант
      User? user = FirebaseAuth.instance.currentUser;

      /// 2) Если null — ждём стрим, но ограничиваемся 3 секундами
      user ??= await _authService.authStateChanges
          .first
          .timeout(const Duration(seconds: 3), onTimeout: () => null);

      if (!mounted) return;

      /// --- Если пользователь НЕ авторизован ---
      if (user == null) {
        await _safeClearLocalData();
        _go(AppRouter.auth);
        return;
      }

      /// --- Пользователь авторизован ---
      /// Синхронизация с тайм-аутом (чтобы не зависнуть)
      await _runWithTimeout(
        _syncService.syncAllFromFirestore(),
        fallback: () => null,
      );

      if (!mounted) return;

      /// Проверка онбординга (тоже с тайм-аутом)
      final bool isOnboardingComplete = await _runWithTimeout(
        _firestoreService.isOnboardingCompleteInCloud(),
        fallback: () => false,
      );

      if (!mounted) return;

      /// --- Навигация ---
      if (isOnboardingComplete) {
        _go(AppRouter.home);
      } else {
        _go(AppRouter.onboarding);
      }
    } catch (e) {
      await _safeClearLocalData();
      if (mounted) _go(AppRouter.auth);
    }
  }

  /// Безопасный вызов очистки, чтобы не упасть
  Future<void> _safeClearLocalData() async {
    try {
      await _runWithTimeout(
        _syncService.clearAllLocalData(),
        fallback: () => null,
      );
    } catch (_) {}
  }

  /// Функция тайм-аута
  Future<T> _runWithTimeout<T>(Future<T> future, {required T Function() fallback}) async {
    try {
      return await future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return fallback();
    } catch (_) {
      return fallback();
    }
  }

  /// Унифицированная навигация
  void _go(String route) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return const _LoadingScreen();
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/lottie/loading_indicator.json',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
