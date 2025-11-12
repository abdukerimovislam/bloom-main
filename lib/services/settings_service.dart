// Файл: lib/services/settings_service.dart

import 'package:bloom/services/firestore_service.dart'; // <-- ИЗМЕНЕНИЕ
import 'package:bloom/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // --- ИЗМЕНЕНИЕ: Добавляем FirestoreService ---
  final FirestoreService _firestore = FirestoreService();
  // ---

  static const String _keyNotificationsEnabled = 'notificationsEnabled';
  static const String _keyAppLocale = 'appLocale';
  static const String _keyAppTheme = 'appTheme';
  static const String _keyUseManualCycleLength = 'useManualCycleLength';
  static const String _keyIsPillTrackerEnabled = 'isPillTrackerEnabled';
  static const String _keyPillReminderTime = 'pillReminderTime';
  static const String _keyPillPackStartDate = 'pillPackStartDate';
  static const String _keyPillActiveDays = 'pillActiveDays';
  static const String _keyPillPlaceboDays = 'pillPlaceboDays';

  // --- ИЗМЕНЕНИЕ: Новые ключи для настроек цикла ---
  // (Мы переносим их из cycle_service)
  static const String _keyAvgCycleLengthManual = 'avgCycleLengthManual';
  static const String _keyAvgPeriodLengthManual = 'avgPeriodLengthManual';
  // ---


  // --- ИЗМЕНЕНИЕ: Новый метод "Скачивания" ---
  /// Скачивает все настройки из Firestore и сохраняет их в SharedPreferences
  Future<void> syncFromFirestore() async {
    final data = await _firestore.loadSettings();
    if (data == null) return; // Нет данных в облаке

    final prefs = await SharedPreferences.getInstance();

    // Безопасно проходим по всем ключам
    if (data[_keyNotificationsEnabled] != null) {
      await prefs.setBool(_keyNotificationsEnabled, data[_keyNotificationsEnabled]);
    }
    if (data[_keyAppLocale] != null) {
      await prefs.setString(_keyAppLocale, data[_keyAppLocale]);
    }
    if (data[_keyAppTheme] != null) {
      await prefs.setString(_keyAppTheme, data[_keyAppTheme]);
    }
    if (data[_keyUseManualCycleLength] != null) {
      await prefs.setBool(_keyUseManualCycleLength, data[_keyUseManualCycleLength]);
    }
    if (data[_keyIsPillTrackerEnabled] != null) {
      await prefs.setBool(_keyIsPillTrackerEnabled, data[_keyIsPillTrackerEnabled]);
    }
    if (data[_keyPillReminderTime] != null) {
      await prefs.setString(_keyPillReminderTime, data[_keyPillReminderTime]);
    }
    if (data[_keyPillPackStartDate] != null) {
      await prefs.setString(_keyPillPackStartDate, data[_keyPillPackStartDate]);
    }
    if (data[_keyPillActiveDays] != null) {
      await prefs.setInt(_keyPillActiveDays, data[_keyPillActiveDays]);
    }
    if (data[_keyPillPlaceboDays] != null) {
      await prefs.setInt(_keyPillPlaceboDays, data[_keyPillPlaceboDays]);
    }
    // Синхронизируем настройки цикла
    if (data[_keyAvgCycleLengthManual] != null) {
      await prefs.setInt(_keyAvgCycleLengthManual, data[_keyAvgCycleLengthManual]);
    }
    if (data[_keyAvgPeriodLengthManual] != null) {
      await prefs.setInt(_keyAvgPeriodLengthManual, data[_keyAvgPeriodLengthManual]);
    }
  }
  // ---

  // --- ИЗМЕНЕНИЕ: Все 'set' методы теперь вызывают _firestore.saveSettings ---

  Future<void> setNotificationsEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, isEnabled);
    await _firestore.saveSettings({_keyNotificationsEnabled: isEnabled}); // <-- Бэкап
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<void> setAppLocale(String localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppLocale, localeCode);
    await _firestore.saveSettings({_keyAppLocale: localeCode}); // <-- Бэкап
  }

  Future<String?> getAppLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAppLocale);
  }

  Future<void> setAppTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = AppThemes.themeToString(theme);
    await prefs.setString(_keyAppTheme, themeString);
    await _firestore.saveSettings({_keyAppTheme: themeString}); // <-- Бэкап
  }

  Future<AppTheme> getAppTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_keyAppTheme);
    return AppThemes.stringToTheme(themeString);
  }

  Future<void> setUseManualCycleLength(bool useManual) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseManualCycleLength, useManual);
    await _firestore.saveSettings({_keyUseManualCycleLength: useManual}); // <-- Бэкап
  }

  Future<bool> getUseManualCycleLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUseManualCycleLength) ?? false;
  }

  Future<void> setIsPillTrackerEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPillTrackerEnabled, isEnabled);
    await _firestore.saveSettings({_keyIsPillTrackerEnabled: isEnabled}); // <-- Бэкап
  }

  Future<bool> isPillTrackerEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPillTrackerEnabled) ?? false;
  }

  Future<void> setPillReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    await prefs.setString(_keyPillReminderTime, timeString);
    await _firestore.saveSettings({_keyPillReminderTime: timeString}); // <-- Бэкап
  }

  Future<TimeOfDay?> getPillReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_keyPillReminderTime);
    if (timeString == null) return null;
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  Future<void> savePillPackSettings(DateTime? startDate, int activeDays, int placeboDays) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> dataToSave = {};

    if (startDate == null) {
      await prefs.remove(_keyPillPackStartDate);
      dataToSave[_keyPillPackStartDate] = null;
    } else {
      final dateString = startDate.toIso8601String();
      await prefs.setString(_keyPillPackStartDate, dateString);
      dataToSave[_keyPillPackStartDate] = dateString;
    }

    await prefs.setInt(_keyPillActiveDays, activeDays);
    dataToSave[_keyPillActiveDays] = activeDays;

    await prefs.setInt(_keyPillPlaceboDays, placeboDays);
    dataToSave[_keyPillPlaceboDays] = placeboDays;

    await _firestore.saveSettings(dataToSave); // <-- Бэкап (сразу 3 поля)
  }

  Future<DateTime?> getPillPackStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keyPillPackStartDate);
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  Future<int> getPillActiveDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyPillActiveDays) ?? 21;
  }

  Future<int> getPillPlaceboDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyPillPlaceboDays) ?? 7;
  }

  // --- ИЗМЕНЕНИЕ: Новые методы (перенесены из cycle_service) ---
  Future<void> saveManualAvgCycleLength(int length) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAvgCycleLengthManual, length);
    await _firestore.saveSettings({_keyAvgCycleLengthManual: length}); // <-- Бэкап
  }
  Future<int> getManualAvgCycleLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAvgCycleLengthManual) ?? 28;
  }
  Future<void> saveManualAvgPeriodLength(int length) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAvgPeriodLengthManual, length);
    await _firestore.saveSettings({_keyAvgPeriodLengthManual: length}); // <-- Бэкап
  }
  Future<int> getManualAvgPeriodLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAvgPeriodLengthManual) ?? 5;
  }
// ---
}