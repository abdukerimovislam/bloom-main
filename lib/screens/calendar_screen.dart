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
    HapticFeedback.lightImpact();

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
    HapticFeedback.mediumImpact();
    if (selectedDay.isAfter(DateTime.now())) {
      return;
    }
    _showSymptomSheetForDate(_normalizeDate(selectedDay));
  }

  void _showSymptomSheetForDate(DateTime date) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SymptomSheet(
              selectedDate: date,
            ),
          ),
        );
      },
    ).then((_) {
      _loadData();
    });
  }

  Future<void> _saveAndReload() async {
    await _cycleService.savePeriodDays(_periodDays.toList());
    await _cycleService.saveBleedingDays(_bleedingDays.toList());
    await _loadData();
  }

  Widget _buildCalendarDay(BuildContext context, DateTime day, DateTime focusedDay, AppLocalizations l10n, ColorScheme colors) {
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

    final bool isEmpty = _periodDays.isEmpty && _bleedingDays.isEmpty && _prediction == null;

    return Scaffold(
      // --- УЛУЧШЕНИЕ: Градиентный фон ---
      backgroundColor: theme.colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.background,
              theme.colorScheme.surface.withOpacity(0.3),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- УЛУЧШЕНИЕ: Карточка для календаря ---
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TableCalendar(
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
                    calendarStyle: CalendarStyle(
                      markerDecoration: BoxDecoration(),
                      todayDecoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      defaultDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      weekendDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      outsideDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      titleTextStyle: theme.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      formatButtonVisible: false,
                      leftChevronIcon: Icon(Icons.chevron_left, color: colors.primary),
                      rightChevronIcon: Icon(Icons.chevron_right, color: colors.primary),
                      headerPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                      weekendStyle: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface.withOpacity(0.7),
                      ),
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
                ),
              ),
              const SizedBox(height: 24),

              // --- УЛУЧШЕНИЕ: Красивое пустое состояние ---
              if (isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.calendarEmptyState,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.tapToLogPeriod,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.calendarLongPressHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // --- УЛУЧШЕНИЕ: Красивая легенда ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Legend',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LegendItem(
                      color: colors.primary,
                      label: l10n.calendarLegendPeriod,
                    ),
                    if (_isPillTrackerEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: _LegendItem(
                          color: colors.primaryContainer,
                          label: l10n.calendarLegendBleeding,
                        ),
                      ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: colors.secondaryContainer.withOpacity(0.5),
                      label: l10n.calendarLegendFertile,
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: Colors.transparent,
                      borderColor: colors.primary.withOpacity(0.7),
                      label: l10n.calendarLegendPredicted,
                    ),
                    const SizedBox(height: 16),
                    _LegendIconItem(
                      icon: Icons.circle,
                      iconSize: 5,
                      label: l10n.symptomsTitle,
                    ),
                    if (_isPillTrackerEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: _LegendIconItem(
                          icon: Icons.medication_outlined,
                          label: l10n.calendarLegendPill,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: _LegendIconItem(
                        icon: Icons.notes_rounded,
                        label: l10n.calendarLegendNote,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Виджет для одного пункта в легенде
class _LegendItem extends StatelessWidget {
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
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: borderColor ?? color,
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Виджет для иконок в легенде
class _LegendIconItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? iconSize;

  const _LegendIconItem({
    required this.icon,
    required this.label,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize ?? 14,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Виджет для одного дня в календаре
class _DayMarker extends StatelessWidget {
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
    Color finalTextColor = textColor;

    if (isSelected) {
      border = Border.all(color: colors.primary, width: 2);
      finalTextColor = colors.primary;
    } else if (borderColor != null) {
      border = Border.all(color: borderColor!, width: 2);
    } else if (isToday) {
      border = Border.all(color: colors.primary.withOpacity(0.5), width: 1.5);
      finalTextColor = colors.primary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: border,
        boxShadow: isSelected ? [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasNote)
            Positioned(
              top: 2,
              left: 2,
              child: Icon(
                Icons.notes_rounded,
                size: 8,
                color: isSelected ? colors.primary : finalTextColor.withOpacity(0.6),
              ),
            ),

          Center(
            child: Text(
              day,
              style: TextStyle(
                color: finalTextColor,
                fontSize: 12,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          if (hasSymptoms)
            Positioned(
              bottom: 2,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : finalTextColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),

          if (hasPill)
            Positioned(
              top: 2,
              child: Icon(
                Icons.medication_outlined,
                size: 8,
                color: isSelected ? colors.primary : finalTextColor,
              ),
            ),
        ],
      ),
    );
  }
}