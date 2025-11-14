// Файл: lib/services/pill_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// --- ИЗМЕНЕНИЕ: Импортируем FirestoreService ---
import 'package:bloom/services/firestore_service.dart';

class PillService {
  // --- ИЗМЕНЕНИЕ: Инициализируем FirestoreService ---
  final FirestoreService _firestore = FirestoreService();

  static const String _pillDaysKey = 'pillTakenDays';

  String _normalizeDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Возвращает Set всех дат, когда таблетка была принята
  Future<Set<DateTime>> getPillDays() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getStringList(_pillDaysKey) ?? [];

    return index
        .map((dateString) => DateTime.tryParse(dateString))
        .where((date) => date != null)
        .cast<DateTime>()
        .toSet();
  }

  /// Проверяет, была ли таблетка принята в конкретный день
  Future<bool> isPillTaken(DateTime date) async {
    final days = await getPillDays();
    return days.contains(DateTime(date.year, date.month, date.day));
  }

  /// Отмечает таблетку как принятую
  Future<void> savePillTaken(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = _normalizeDate(date);

    final index = (prefs.getStringList(_pillDaysKey) ?? []).toSet();

    if (!index.contains(dateString)) {
      index.add(dateString);
      await prefs.setStringList(_pillDaysKey, index.toList());
      // TODO: Добавить бэкап в Firestore
      // await _firestore.updateUserPillData({
      //   _pillDaysKey: index.toList(),
      // });
    }
  }

  /// (Пока не используется, но понадобится для блистера)
  Future<void> removePillTaken(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = _normalizeDate(date);

    final index = (prefs.getStringList(_pillDaysKey) ?? []).toSet();

    if (index.contains(dateString)) {
      index.remove(dateString);
      await prefs.setStringList(_pillDaysKey, index.toList());
      // TODO: Добавить бэкап в Firestore
      // await _firestore.updateUserPillData({
      //   _pillDaysKey: index.toList(),
      // });
    }
  }

  // ---
  // --- НОВЫЕ МЕТОДЫ ДЛЯ СИНХРОНИЗАЦИИ ---
  // ---

  /// Скачивает данные о таблетках из Firestore и сохраняет локально
  Future<void> syncFromFirestore() async {
    print("🔄 Синхронизация PillService...");

    // 1. Получаем данные из Firestore
    // (Предполагается, что у вас есть такой метод в FirestoreService)
    final Map<String, dynamic>? firestoreData = await _firestore.getUserPillData();

    if (firestoreData != null) {
      final prefs = await SharedPreferences.getInstance();

      // 2. Восстанавливаем дни приема таблеток
      final pillDays = (firestoreData[_pillDaysKey] as List<dynamic>?)
          ?.map((d) => d.toString()) // Предполагаем, что в Firestore они хранятся как String или Timestamp
          .toList() ?? [];

      await prefs.setStringList(_pillDaysKey, pillDays);
    }
  }

  /// Очищает локальные данные о таблетках при выходе
  Future<void> clearLocalData() async {
    print("🧹 Очистка PillService...");
    final prefs = await SharedPreferences.getInstance();

    // Удаляем все ключи, за которые отвечает этот сервис
    await prefs.remove(_pillDaysKey);
  }
}