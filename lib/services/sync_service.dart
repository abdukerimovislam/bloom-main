// Файл: lib/services/sync_service.dart

import 'package:bloom/services/settings_service.dart';
import 'package:bloom/services/cycle_service.dart';
import 'package:bloom/services/symptom_service.dart';
import 'package:bloom/services/pill_service.dart';

/// Сервис-координатор для управления синхронизацией данных.
/// Абстрагирует логику "скачать все" и "очистить все"
/// от AuthGate.
class SyncService {
  // Получаем экземпляры всех сервисов, управляющих данными
  final SettingsService _settingsService = SettingsService();
  final CycleService _cycleService = CycleService();
  final SymptomService _symptomService = SymptomService();
  final PillService _pillService = PillService();

  /// Вызывает [syncFromFirestore] у всех сервисов.
  /// Скачивает данные из Firestore и сохраняет их локально
  /// (в SharedPreferences).
  Future<void> syncAllFromFirestore() async {
    print("🔄 SyncService: Начинается полная синхронизация из Firestore...");
    try {
      // Запускаем все синхронизации параллельно для максимальной скорости
      await Future.wait([
        _settingsService.syncFromFirestore(),
        _cycleService.syncFromFirestore(),
        _symptomService.syncFromFirestore(),
        _pillService.syncFromFirestore(),
      ]);
      print("✅ SyncService: Полная синхронизация завершена.");
    } catch (e) {
      print("❌ SyncService: Ошибка во время синхронизации: $e");
      // Пробрасываем ошибку выше (в AuthGate), чтобы он мог
      // обработать ее (например, разлогинить пользователя)
      rethrow;
    }
  }

  /// Вызывает [clearLocalData] у всех сервисов.
  /// Используется при выходе пользователя, чтобы очистить все
  /// локальные данные (SharedPreferences).
  Future<void> clearAllLocalData() async {
    print("🧹 SyncService: Очистка всех локальных данных пользователя...");
    try {
      // Также запускаем параллельно
      await Future.wait([
        _settingsService.clearLocalData(),
        _cycleService.clearLocalData(),
        _symptomService.clearLocalData(),
        _pillService.clearLocalData(),
      ]);
      print("✅ SyncService: Локальные данные очищены.");
    } catch (e) {
      print("❌ SyncService: Ошибка при очистке локальных данных: $e");
      // Здесь мы НЕ пробрасываем ошибку.
      // Пользователь должен быть разлогинен, даже если очистка не удалась.
    }
  }
}