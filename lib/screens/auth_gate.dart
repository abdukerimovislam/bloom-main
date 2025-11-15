// Файл: lib/screens/auth_gate.dart

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
    // Вызываем нашу одноразовую функцию проверки
    _handleAuthCheck();
  }

  /// Эта функция запускается ОДИН РАЗ и решает, куда
  /// перенаправить пользователя.
  Future<void> _handleAuthCheck() async {
    try {
      // --- КЛЮЧЕВОЕ ИЗМЕНЕНИЕ ---
      // Мы ждем ТОЛЬКО ПЕРВОГО ответа от Firebase.
      // Это Future, а не Stream, поэтому он выполнится 1 раз.
      final User? user = await _authService.authStateChanges.first;
      // ---

      // Убедимся, что виджет не был удален, пока мы ждали
      if (!mounted) return;

      if (user == null) {
        // --- СЛУЧАЙ 1: Пользователь НЕ вошел ---
        print('🔒 AuthGate: Пользователь не вошел. Очистка локальных данных...');
        await _syncService.clearAllLocalData();

        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRouter.auth);
        }
      } else {
        // --- СЛУЧАЙ 2: Пользователь ВОШЕЛ ---
        await _syncService.syncAllFromFirestore();

        if (!mounted) return;

        final bool isOnboardingComplete = await _firestoreService.isOnboardingCompleteInCloud();

        if (!mounted) return;

        if (isOnboardingComplete) {
          // 2a: Вошел и все настроил -> на главный экран
          Navigator.of(context).pushReplacementNamed(AppRouter.home);
        } else {
          // 2b: Вошел, но онбординг не пройден -> на экран онбординга
          Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
        }
      }
    } catch (e) {
      if (mounted) {
        await _syncService.clearAllLocalData();
        Navigator.of(context).pushReplacementNamed(AppRouter.auth);
      }
    }
  }

  @override
  void dispose() {
    // Нам больше не нужно отменять подписку,
    // так как мы ее не создавали.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Этот экран будет отображаться, пока _handleAuthCheck
    // выполняет свою асинхронную работу.
    return const _LoadingScreen();
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