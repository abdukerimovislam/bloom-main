// Файл: lib/services/symptom_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloom/services/firestore_service.dart';

class SymptomService {
  final FirestoreService _firestore = FirestoreService();

  // Ключи для SharedPreferences
  static const String _symptomsKey = 'symptoms';
  static const String _notesKey = 'notes'; // <-- НОВЫЙ КЛЮЧ

  // ---
  // --- МЕТОДЫ ДЛЯ СИМПТОМОВ ---
  // ---

  /// Возвращает все симптомы за конкретный день
  Future<Set<String>> getSymptoms(DateTime date) async {
    final allSymptoms = await _getAllSymptoms();
    final dateKey = _normalizeDate(date);
    return allSymptoms[dateKey]?.toSet() ?? {};
  }

  /// Сохраняет симптомы за конкретный день
  Future<void> saveSymptoms(DateTime date, Set<String> symptoms) async {
    final allSymptoms = await _getAllSymptoms();
    final dateKey = _normalizeDate(date);

    if (symptoms.isEmpty) {
      allSymptoms.remove(dateKey);
    } else {
      allSymptoms[dateKey] = symptoms.toList();
    }

    await _saveAllSymptoms(allSymptoms);

    // TODO: Добавить бэкап в Firestore
    // await _firestore.updateUserSymptomData(allSymptoms);
  }

  // ---
  // --- НОВЫЕ МЕТОДЫ ДЛЯ ЗАМЕТОК ---
  // ---

  /// Возвращает заметку за конкретный день
  Future<String> getNote(DateTime date) async {
    final allNotes = await _getAllNotes();
    final dateKey = _normalizeDate(date);
    return allNotes[dateKey] ?? "";
  }

  /// Сохраняет заметку за конкретный день
  Future<void> saveNote(DateTime date, String note) async {
    final allNotes = await _getAllNotes();
    final dateKey = _normalizeDate(date);

    if (note.isEmpty) {
      allNotes.remove(dateKey);
    } else {
      allNotes[dateKey] = note;
    }

    await _saveAllNotes(allNotes);

    // TODO: Добавить бэкап в Firestore
    // await _firestore.updateUserNoteData(allNotes);
  }

  // ---
  // --- НОВЫЕ МЕТОДЫ ДЛЯ КАЛЕНДАРЯ ---
  // ---

  /// Возвращает Set дат, в которых есть симптомы
  Future<Set<String>> getSymptomDaysIndex() async {
    final allSymptoms = await _getAllSymptoms();
    return allSymptoms.keys.toSet();
  }

  /// Возвращает Set дат, в которых есть заметки
  Future<Set<String>> getNoteDaysIndex() async {
    final allNotes = await _getAllNotes();
    return allNotes.keys.toSet();
  }

  // ---
  // --- ВНУТРЕННИЕ ХЕЛПЕРЫ ---
  // ---

  String _normalizeDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Хелперы для симптомов (Map<String, List<String>>)
  Future<Map<String, List<String>>> _getAllSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_symptomsKey);
    if (jsonString == null) return {};
    try {
      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return decodedMap.map((key, value) {
        final list = (value as List<dynamic>).map((item) => item.toString()).toList();
        return MapEntry(key, list);
      });
    } catch (e) { return {}; }
  }
  Future<void> _saveAllSymptoms(Map<String, List<String>> allSymptoms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_symptomsKey, jsonEncode(allSymptoms));
  }

  // Хелперы для заметок (Map<String, String>)
  Future<Map<String, String>> _getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notesKey);
    if (jsonString == null) return {};
    try {
      return Map<String, String>.from(jsonDecode(jsonString));
    } catch (e) { return {}; }
  }
  Future<void> _saveAllNotes(Map<String, String> allNotes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notesKey, jsonEncode(allNotes));
  }

  // ---
  // --- ОБНОВЛЕННЫЕ МЕТОДЫ СИНХРОНИЗАЦИИ ---
  // ---

  /// Скачивает симптомы И заметки из Firestore
  Future<void> syncFromFirestore() async {
    print("🔄 Синхронизация SymptomService...");
    final prefs = await SharedPreferences.getInstance();

    // 1. Синхронизируем СИМПТОМЫ
    final Map<String, dynamic>? symptomData = await _firestore.getUserSymptomData();
    if (symptomData != null) {
      final allSymptoms = symptomData.map((key, value) {
        final list = (value as List<dynamic>).map((item) => item.toString()).toList();
        return MapEntry(key, list);
      });
      await prefs.setString(_symptomsKey, jsonEncode(allSymptoms));
    }

    // 2. Синхронизируем ЗАМЕТКИ (предполагаем, что они хранятся как Map<String, String>)
    final Map<String, dynamic>? noteData = await _firestore.getUserNoteData();
    if (noteData != null) {
      final allNotes = noteData.map((key, value) => MapEntry(key, value.toString()));
      await prefs.setString(_notesKey, jsonEncode(allNotes));
    }
  }

  /// Очищает локальные симптомы И заметки
  Future<void> clearLocalData() async {
    print("🧹 Очистка SymptomService...");
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_symptomsKey);
    await prefs.remove(_notesKey); // <-- ОБНОВЛЕНО
  }
}