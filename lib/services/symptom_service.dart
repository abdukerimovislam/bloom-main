// Файл: lib/services/symptom_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SymptomService {
  // Ключи для SharedPreferences
  static const String _prefix = 'symptoms_';
  // --- ИЗМЕНЕНИЕ: Новые ключи для Заметок ---
  static const String _notePrefix = 'note_';
  static const String _allNoteDaysKey = 'allNoteDays';
  // ---
  static const String _allSymptomDaysKey = 'allSymptomDays';

  String _getKey(DateTime date, String prefix) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return '$prefix$dateString';
  }

  String _normalizeDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Сохраняет набор симптомов (и настроений) для определенной даты
  Future<void> saveSymptoms(DateTime date, Set<String> symptoms) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(date, _prefix);

    await prefs.setStringList(key, symptoms.toList());

    // Обновляем индекс дней с СИМПТОМАМИ
    final dateString = _normalizeDate(date);
    final index = (prefs.getStringList(_allSymptomDaysKey) ?? []).toSet();

    if (symptoms.isNotEmpty && !index.contains(dateString)) {
      index.add(dateString);
    } else if (symptoms.isEmpty && index.contains(dateString)) {
      index.remove(dateString);
    }

    await prefs.setStringList(_allSymptomDaysKey, index.toList());
  }

  /// Получает набор симптомов для определенной даты
  Future<Set<String>> getSymptoms(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(date, _prefix);
    final symptomsList = prefs.getStringList(key);
    if (symptomsList == null) {
      return <String>{};
    }
    return symptomsList.toSet();
  }

  /// Возвращает Set всех дат, у которых есть симптомы
  Future<Set<DateTime>> getSymptomDaysIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getStringList(_allSymptomDaysKey) ?? [];

    return index
        .map((dateString) => DateTime.tryParse(dateString))
        .where((date) => date != null)
        .cast<DateTime>()
        .toSet();
  }

  // --- ИЗМЕНЕНИЕ: Новые методы для Заметок ---

  /// Сохраняет текстовую заметку для даты
  Future<void> saveNote(DateTime date, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(date, _notePrefix);

    // 1. Сохраняем заметку
    await prefs.setString(key, note);

    // 2. Обновляем индекс дней с ЗАМЕТКАМИ
    final dateString = _normalizeDate(date);
    final index = (prefs.getStringList(_allNoteDaysKey) ?? []).toSet();

    // Если заметка не пустая - добавляем в индекс
    if (note.trim().isNotEmpty && !index.contains(dateString)) {
      index.add(dateString);
    }
    // Если заметка стала пустой - удаляем из индекса
    else if (note.trim().isEmpty && index.contains(dateString)) {
      index.remove(dateString);
    }

    await prefs.setStringList(_allNoteDaysKey, index.toList());
  }

  /// Получает заметку для даты
  Future<String> getNote(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(date, _notePrefix);
    return prefs.getString(key) ?? ""; // Возвращаем пустую строку, если null
  }

  /// Возвращает Set всех дат, у которых есть заметки
  Future<Set<DateTime>> getNoteDaysIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getStringList(_allNoteDaysKey) ?? [];

    return index
        .map((dateString) => DateTime.tryParse(dateString))
        .where((date) => date != null)
        .cast<DateTime>()
        .toSet();
  }
// ---
}