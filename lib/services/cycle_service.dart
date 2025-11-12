// Файл: lib/services/cycle_service.dart

import 'dart:math';
import 'package:bloom/models/cycle_prediction.dart';
import 'package:bloom/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// --- ИЗМЕНЕНИЕ: Импортируем FirestoreService ---
import 'package:bloom/services/firestore_service.dart';
// ---

class CycleService {
  final FirestoreService _firestore = FirestoreService();

  // Ключи для Месячных
  static const String _keyPeriodDays = 'periodDays';
  static const String _keyIsPeriodActive = 'isPeriodActive';
  static const String _keyActivePeriodStart = 'activePeriodStart';

  // Ключи для Кровотечения
  static const String _keyBleedingDays = 'bleedingDays';
  static const String _keyIsBleedingActive = 'isBleedingActive';
  static const String _keyActiveBleedingStart = 'activeBleedingStart';

  // --- ИЗМЕНЕНИЕ: УДАЛЕНЫ КЛЮЧИ НАСТРОЕК ---
  // static const String _keyAvgCycleLengthManual = 'avgCycleLengthManual';
  // static const String _keyOnboardingComplete = 'onboardingComplete';
  // static const String _keyAvgPeriodLengthManual = 'avgPeriodLengthManual';
  // ---

  // --- (Методы для _periodDays: savePeriodDays, getPeriodDays) ---
  Future<void> savePeriodDays(List<DateTime> dates) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStrings = dates.map((date) => date.toString()).toList();
    await prefs.setStringList(_keyPeriodDays, dateStrings);
    // TODO: Добавить бэкап в Firestore
  }
  Future<List<DateTime>> getPeriodDays() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStrings = prefs.getStringList(_keyPeriodDays);
    if (dateStrings == null) return [];
    final dates = dateStrings
        .map((dateString) => DateTime.tryParse(dateString))
        .where((date) => date != null)
        .cast<DateTime>()
        .toList();
    return dates;
  }
  // ---

  // --- (Методы для isPeriodActive: isPeriodActive, getActivePeriodStart, startPeriod, endPeriod) ---
  Future<bool> isPeriodActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPeriodActive) ?? false;
  }
  Future<DateTime?> getActivePeriodStart() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keyActivePeriodStart);
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }
  Future<void> startPeriod(DateTime startDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPeriodActive, true);
    await prefs.setString(_keyActivePeriodStart, startDate.toIso8601String());
    // TODO: Добавить бэкап в Firestore
  }
  Future<void> endPeriod() async {
    final prefs = await SharedPreferences.getInstance();
    final startDate = await getActivePeriodStart();
    final endDate = DateTime.now();
    final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day);

    if (startDate != null) {
      final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
      final allPeriodDays = await getPeriodDays();
      final existingDates = allPeriodDays.map((d) => DateTime(d.year, d.month, d.day)).toSet();
      final List<DateTime> newDays = [];
      DateTime currentDate = normalizedStartDate;
      if (!normalizedEndDate.isBefore(normalizedStartDate)) {
        while (currentDate.difference(normalizedEndDate).inDays <= 0) {
          final dateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
          if (!existingDates.contains(dateOnly)) { newDays.add(dateOnly); }
          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
      if (newDays.isNotEmpty) { await savePeriodDays(allPeriodDays + newDays); }
    }
    await prefs.setBool(_keyIsPeriodActive, false);
    await prefs.remove(_keyActivePeriodStart);
    // TODO: Добавить бэкап в Firestore
  }
  // ---

  // --- (Методы для Bleeding) ---
  Future<void> saveBleedingDays(List<DateTime> dates) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStrings = dates.map((date) => date.toString()).toList();
    await prefs.setStringList(_keyBleedingDays, dateStrings);
    // TODO: Добавить бэкап в Firestore
  }
  Future<List<DateTime>> getBleedingDays() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStrings = prefs.getStringList(_keyBleedingDays);
    if (dateStrings == null) return [];
    final dates = dateStrings
        .map((dateString) => DateTime.tryParse(dateString))
        .where((date) => date != null)
        .cast<DateTime>()
        .toList();
    return dates;
  }
  Future<bool> isBleedingActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsBleedingActive) ?? false;
  }
  Future<DateTime?> getActiveBleedingStart() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keyActiveBleedingStart);
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }
  Future<void> startBleeding(DateTime startDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsBleedingActive, true);
    await prefs.setString(_keyActiveBleedingStart, startDate.toIso8601String());
    // TODO: Добавить бэкап в Firestore
  }
  Future<void> endBleeding() async {
    final prefs = await SharedPreferences.getInstance();
    final startDate = await getActiveBleedingStart();
    final endDate = DateTime.now();
    final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day);

    if (startDate != null) {
      final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
      final allBleedingDays = await getBleedingDays();
      final existingDates = allBleedingDays.map((d) => DateTime(d.year, d.month, d.day)).toSet();
      final List<DateTime> newDays = [];
      DateTime currentDate = normalizedStartDate;
      if (!normalizedEndDate.isBefore(normalizedStartDate)) {
        while (currentDate.difference(normalizedEndDate).inDays <= 0) {
          final dateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
          if (!existingDates.contains(dateOnly)) { newDays.add(dateOnly); }
          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
      if (newDays.isNotEmpty) { await saveBleedingDays(allBleedingDays + newDays); }
    }
    await prefs.setBool(_keyIsBleedingActive, false);
    await prefs.remove(_keyActiveBleedingStart);
    // TODO: Добавить бэкап в Firestore
  }
  // ---

  // --- ИЗМЕНЕНИЕ: УДАЛЕНЫ методы save/get Manual... и onboarding... ---
  // (Они переехали в SettingsService и FirestoreService)
  // ---

  Future<CyclePrediction?> getCyclePredictions() async {
    final settingsService = SettingsService();
    final bool isPillEnabled = await settingsService.isPillTrackerEnabled();
    if (isPillEnabled) {
      return null;
    }

    final periodDays = await getPeriodDays();
    if (periodDays.isEmpty) return null;

    final periodGroups = _groupDays(periodDays, 2);

    // --- ИЗМЕНЕНИЕ: Загружаем настройки из SettingsService ---
    final int avgPeriodLength;
    if (periodGroups.isEmpty) {
      avgPeriodLength = await settingsService.getManualAvgPeriodLength();
    } else {
      final totalPeriodDays = periodGroups.fold<int>(0, (sum, group) => sum + group.length);
      avgPeriodLength = (totalPeriodDays / periodGroups.length).round();
    }

    final startDates = periodGroups.map((group) => group.first).toList();
    int avgCycleLength;

    final bool useManual = await settingsService.getUseManualCycleLength();
    final int manualLength = await settingsService.getManualAvgCycleLength();
    // ---

    if (useManual) {
      avgCycleLength = manualLength;
    } else {

      if (startDates.length < 2) {
        avgCycleLength = manualLength;
      } else {
        final List<int> cycleLengths = [];
        for (int i = 0; i < startDates.length - 1; i++) {
          final length = startDates[i + 1].difference(startDates[i]).inDays;
          cycleLengths.add(length);
        }

        if (cycleLengths.length >= 4) {
          cycleLengths.sort();
          final stableLengths = cycleLengths.sublist(1, cycleLengths.length - 1);
          avgCycleLength = (stableLengths.reduce((a, b) => a + b) / stableLengths.length).round();
        } else {
          avgCycleLength = cycleLengths.isEmpty
              ? manualLength
              : (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round();
        }
      }
    }

    if (startDates.isEmpty && periodDays.isNotEmpty) {
      startDates.add(periodDays.first);
    } else if (startDates.isEmpty && periodDays.isEmpty) {
      return null;
    }

    final lastPeriodStartDate = startDates.last;

    final nextPeriodStartDate = lastPeriodStartDate.add(Duration(days: avgCycleLength));
    final nextOvulationDate = nextPeriodStartDate.subtract(const Duration(days: 14));
    final fertileWindowStart = nextOvulationDate.subtract(const Duration(days: 5));
    final fertileWindowEnd = nextOvulationDate;

    return CyclePrediction(
      avgCycleLength: avgCycleLength,
      avgPeriodLength: max(1, avgPeriodLength),
      lastPeriodStartDate: lastPeriodStartDate,
      nextPeriodStartDate: nextPeriodStartDate,
      nextOvulationDate: nextOvulationDate,
      fertileWindowStart: fertileWindowStart,
      fertileWindowEnd: fertileWindowEnd,
    );
  }

  List<List<DateTime>> _groupDays(List<DateTime> days, int maxGap) {
    if (days.isEmpty) return [];
    days.sort((a, b) => a.compareTo(b));
    List<List<DateTime>> groups = [];
    List<DateTime> currentGroup = [days.first];
    for (int i = 1; i < days.length; i++) {
      final prevDay = days[i - 1];
      final currentDay = days[i];
      if (currentDay.difference(prevDay).inDays <= maxGap) {
        currentGroup.add(currentDay); // <-- Исправленная опечатка
      } else {
        groups.add(currentGroup);
        currentGroup = [currentDay];
      }
    }
    groups.add(currentGroup);
    return groups;
  }
}