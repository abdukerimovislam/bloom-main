// Файл: lib/screens/calendar_screen.dart

import 'package:bloom/models/cycle_prediction.dart';
import 'package:bloom/services/cycle_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bloom/l10n/app_localizations.dart';

import 'package:bloom/services/symptom_service.dart';
import 'package:bloom/services/pill_service.dart';
import 'package:bloom/services/settings_service.dart';
import 'package:bloom/widgets/symptom_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CycleService _cycleService = CycleService();
  final SymptomService _symptomService = SymptomService();
  final PillService _pillService = PillService();
  final SettingsService _settingsService = SettingsService();

  // ... (состояния без изменений) ...
  CyclePrediction? _prediction;
  Set<DateTime> _periodDays = {};
  Set<DateTime> _predictedPeriodDays = {};
  Set<DateTime> _fertileDays = {};
  Set<DateTime> _symptomDays = {};
  Set<DateTime> _pillDays = {};
  bool _isPillTrackerEnabled = false;
  Set<DateTime> _noteDays = {};
  Set<DateTime> _bleedingDays = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _loadData() async {
    // ... (без изменений) ...
    final isPillEnabled = await _settingsService.isPillTrackerEnabled();

    final results = await Future.wait([
      _cycleService.getPeriodDays(),
      _cycleService.getCyclePredictions(),
      _symptomService.getSymptomDaysIndex(),
      isPillEnabled ? _pillService.getPillDays() : Future.value(<DateTime>{}),
      _symptomService.getNoteDaysIndex(),
      _cycleService.getBleedingDays(),
    ]);

    final periodDaysList = results[0] as List<DateTime>;
    final predictionData = results[1] as CyclePrediction?;
    final symptomDaysIndex = results[2] as Set<DateTime>;
    final pillDaysIndex = results[3] as Set<DateTime>;
    final noteDaysIndex = results[4] as Set<DateTime>;
    final bleedingDaysList = results[5] as List<DateTime>;

    final newPeriodDays = periodDaysList.map(_normalizeDate).toSet();
    final newBleedingDays = bleedingDaysList.map(_normalizeDate).toSet();

    final newPredictedPeriodDays = <DateTime>{};
    final newFertileDays = <DateTime>{};

    if (predictionData != null) {
      DateTime fertileDay = predictionData.fertileWindowStart;
      while (fertileDay.isBefore(predictionData.fertileWindowEnd.add(const Duration(days: 1)))) {
        newFertileDays.add(_normalizeDate(fertileDay));
        fertileDay = fertileDay.add(const Duration(days: 1));
      }
      DateTime predictedDay = predictionData.nextPeriodStartDate;
      for (int i = 0; i < predictionData.avgPeriodLength; i++) {
        newPredictedPeriodDays.add(_normalizeDate(predictedDay));
        predictedDay = predictedDay.add(const Duration(days: 1));
      }
    }

    if (mounted) {
      setState(() {
        _isPillTrackerEnabled = isPillEnabled;
        _periodDays = newPeriodDays;
        _bleedingDays = newBleedingDays;
        _prediction = predictionData;
        _predictedPeriodDays = newPredictedPeriodDays;
        _fertileDays = newFertileDays;
        _symptomDays = symptomDaysIndex;
        _pillDays = pillDaysIndex;
        _noteDays = noteDaysIndex;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // --- ИЗМЕНЕНИЕ: Добавляем HapticFeedback (Улучшение №2) ---
    HapticFeedback.lightImpact();
    // ---

    final normalizedSelectedDay = _normalizeDate(selectedDay);

    setState(() {
      _selectedDay = normalizedSelectedDay;
      _focusedDay = focusedDay;

      if (normalizedSelectedDay.isAfter(_normalizeDate(DateTime.now()))) {
        return;
      }

      if (_isPillTrackerEnabled) {
        if (_bleedingDays.contains(normalizedSelectedDay)) {
          _bleedingDays.remove(normalizedSelectedDay);
        } else {
          _bleedingDays.add(normalizedSelectedDay);
        }
      }
      else {
        if (_periodDays.contains(normalizedSelectedDay)) {
          _periodDays.remove(normalizedSelectedDay);
        } else {
          _periodDays.add(normalizedSelectedDay);
        }
      }
      _saveAndReload();
    });
  }

  void _onDayLongPressed(DateTime selectedDay, DateTime focusedDay) {
    // ... (без изменений) ...
    HapticFeedback.mediumImpact();
    if (selectedDay.isAfter(DateTime.now())) {
      return;
    }
    _showSymptomSheetForDate(_normalizeDate(selectedDay));
  }

  void _showSymptomSheetForDate(DateTime date) {
    // ... (без изменений) ...
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SymptomSheet(
            selectedDate: date,
          ),
        );
      },
    ).then((_) {
      _loadData();
    });
  }

  Future<void> _saveAndReload() async {
    // ... (без изменений) ...
    await _cycleService.savePeriodDays(_periodDays.toList());
    await _cycleService.saveBleedingDays(_bleedingDays.toList());

    await _loadData();
  }

  Widget _buildCalendarDay(BuildContext context, DateTime day, DateTime focusedDay, AppLocalizations l10n, ColorScheme colors) {
    // ... (без изменений) ...
    final normalizedDay = _normalizeDate(day);
    bool isSelected = isSameDay(_selectedDay, normalizedDay);
    bool isToday = isSameDay(normalizedDay, _normalizeDate(DateTime.now()));

    bool hasSymptoms = _symptomDays.contains(normalizedDay);
    bool hasPill = _pillDays.contains(normalizedDay);
    bool hasNote = _noteDays.contains(normalizedDay);

    if (_isPillTrackerEnabled && _bleedingDays.contains(normalizedDay)) {
      return _DayMarker(
        day: day.day.toString(),
        color: colors.primaryContainer,
        textColor: colors.onPrimaryContainer,
        isSelected: isSelected,
        isToday: isToday,
        hasSymptoms: hasSymptoms,
        hasPill: hasPill,
        hasNote: hasNote,
      );
    }

    if (_periodDays.contains(normalizedDay)) {
      return _DayMarker(
        day: day.day.toString(),
        color: colors.primary,
        textColor: colors.onPrimary,
        isSelected: isSelected,
        isToday: isToday,
        hasSymptoms: hasSymptoms,
        hasPill: hasPill,
        hasNote: hasNote,
      );
    }

    if (_fertileDays.contains(normalizedDay)) {
      return _DayMarker(
        day: day.day.toString(),
        color: colors.secondaryContainer.withOpacity(0.5),
        textColor: colors.onSecondaryContainer,
        isSelected: isSelected,
        isToday: isToday,
        hasSymptoms: hasSymptoms,
        hasPill: hasPill,
        hasNote: hasNote,
      );
    }

    if (_predictedPeriodDays.contains(normalizedDay)) {
      return _DayMarker(
        day: day.day.toString(),
        color: Colors.transparent,
        textColor: colors.onBackground,
        isSelected: isSelected,
        isToday: isToday,
        borderColor: colors.primary.withOpacity(0.7),
        hasSymptoms: hasSymptoms,
        hasPill: hasPill,
        hasNote: hasNote,
      );
    }

    return _DayMarker(
      day: day.day.toString(),
      color: Colors.transparent,
      textColor: colors.onBackground,
      isSelected: isSelected,
      isToday: isToday,
      hasSymptoms: hasSymptoms,
      hasPill: hasPill,
      hasNote: hasNote,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // --- ИЗМЕНЕНИЕ: Флаг для "пустого" состояния ---
    final bool isEmpty = _periodDays.isEmpty && _bleedingDays.isEmpty && _prediction == null;
    // ---

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              // ... (все свойства TableCalendar без изменений) ...
              locale: l10n.localeName,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onDayLongPressed: _onDayLongPressed,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                _loadData();
              },
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(),
                todayDecoration: BoxDecoration(),
                selectedDecoration: BoxDecoration(),
                defaultDecoration: BoxDecoration(),
                weekendDecoration: BoxDecoration(),
                outsideDecoration: BoxDecoration(),
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextStyle: theme.textTheme.titleLarge!,
                formatButtonVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildCalendarDay(context, day, focusedDay, l10n, colors);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildCalendarDay(context, day, focusedDay, l10n, colors);
                },
                selectedBuilder: (context, day, focusedDay) {
                  return _buildCalendarDay(context, day, focusedDay, l10n, colors);
                },
                outsideBuilder: (context, day, focusedDay) {
                  return Opacity(
                    opacity: 0.4,
                    child: _buildCalendarDay(context, day, focusedDay, l10n, colors),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- ИЗМЕНЕНИЕ: "Пустое состояние" Календаря (Улучшение №1) ---
            if (isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  l10n.calendarEmptyState,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Column(
                children: [
                  Text(
                    l10n.tapToLogPeriod,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.calendarLongPressHint,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            // ---

            const Divider(height: 32),

            // --- (Остальная Легенда без изменений) ---
            _LegendItem(
              color: colors.primary,
              label: l10n.calendarLegendPeriod,
            ),
            if (_isPillTrackerEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _LegendItem(
                  color: colors.primaryContainer,
                  label: l10n.calendarLegendBleeding,
                ),
              ),
            const SizedBox(height: 8),
            _LegendItem(
              color: colors.secondaryContainer.withOpacity(0.5),
              label: l10n.calendarLegendFertile,
            ),
            const SizedBox(height: 8),
            _LegendItem(
              color: Colors.transparent,
              borderColor: colors.primary.withOpacity(0.7),
              label: l10n.calendarLegendPredicted,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.textTheme.bodyMedium?.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(l10n.symptomsTitle, style: theme.textTheme.bodyMedium),
              ],
            ),
            if (_isPillTrackerEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.medication_outlined,
                        size: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.calendarLegendPill, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.notes_rounded,
                      size: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.calendarLegendNote, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Виджет для одного пункта в легенде
class _LegendItem extends StatelessWidget {
// ... (без изменений) ...
  final Color color;
  final String label;
  final Color? borderColor;

  const _LegendItem({
    required this.color,
    required this.label,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor ?? color,
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

/// Виджет для одного дня в календаре
class _DayMarker extends StatelessWidget {
// ... (без изменений) ...
  final String day;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final bool isSelected;
  final bool isToday;
  final bool hasSymptoms;
  final bool hasPill;
  final bool hasNote;

  const _DayMarker({
    required this.day,
    required this.color,
    required this.textColor,
    this.borderColor,
    required this.isSelected,
    required this.isToday,
    required this.hasSymptoms,
    required this.hasPill,
    required this.hasNote,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    BoxBorder? border;
    if (isSelected) {
      border = Border.all(color: colors.primary, width: 2);
    } else if (borderColor != null) {
      border = Border.all(color: borderColor!, width: 2);
    } else if (isToday) {
      border = Border.all(color: colors.secondary, width: 1.5);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasNote)
            Positioned(
                top: 4,
                left: 4,
                child: Icon(
                  Icons.notes_rounded,
                  size: 10,
                  color: isSelected ? colors.primary : textColor.withOpacity(0.6),
                )
            ),

          Center(
            child: Text(
              day,
              style: TextStyle(
                color: isSelected ? colors.primary : textColor,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          if (hasSymptoms)
            Positioned(
              bottom: 4,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : textColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          if (hasPill)
            Positioned(
                top: 5,
                child: Icon(
                  Icons.medication_outlined,
                  size: 10,
                  color: isSelected ? colors.primary : textColor,
                )
            ),
        ],
      ),
    );
  }
}