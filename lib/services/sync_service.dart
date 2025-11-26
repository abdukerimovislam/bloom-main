// Файл: lib/services/sync_service.dart

import 'dart:async';
import 'package:bloom/services/settings_service.dart';
import 'package:bloom/services/cycle_service.dart';
import 'package:bloom/services/symptom_service.dart';
import 'package:bloom/services/pill_service.dart';

/// Сервис-координатор для управления синхронизацией данных.
class SyncService {
  final SettingsService _settingsService = SettingsService();
  final CycleService _cycleService = CycleService();
  final SymptomService _symptomService = SymptomService();
  final PillService _pillService = PillService();

  bool _isSyncing = false;

  /// Скачивает данные из Firestore и сохраняет локально.
  Future<void> syncAllFromFirestore() async {
    if (_isSyncing) {
      print("⚠️ SyncService: Синхронизация уже выполняется — пропуск вызова");
      return;
    }

    _isSyncing = true;
    print("🔄 SyncService: Начинается полная синхронизация из Firestore...");

    try {
      await Future.wait([
        _settingsService.syncFromFirestore(),
        _cycleService.syncFromFirestore(),
        _symptomService.syncFromFirestore(),
        _pillService.syncFromFirestore(),
      ]).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception("⏳ SyncService: Таймаут синхронизации"),
      );

      print("✅ SyncService: Полная синхронизация завершена");
    } catch (e, stack) {
      print("❌ SyncService: Ошибка во время синхронизации: $e");
      print(stack);
      rethrow; // пробрасываем дальше в AuthGate
    } finally {
      _isSyncing = false;
    }
  }

  /// Полная очистка локальных данных SharedPreferences.
  Future<void> clearAllLocalData() async {
    print("🧹 SyncService: Очистка всех локальных данных...");

    try {
      await Future.wait([
        _settingsService.clearLocalData(),
        _cycleService.clearLocalData(),
        _symptomService.clearLocalData(),
        _pillService.clearLocalData(),
      ]);

      print("✅ SyncService: Локальные данные очищены");
    } catch (e, stack) {
      print("❌ SyncService: Ошибка очистки: $e");
      print(stack);
    }
  }
}
