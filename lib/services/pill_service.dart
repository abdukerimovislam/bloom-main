// Файл: lib/services/pill_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PillService {

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
    }
  }
}