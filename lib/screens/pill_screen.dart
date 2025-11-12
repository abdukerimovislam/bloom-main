// Файл: lib/screens/pill_screen.dart

import 'package:bloom/l10n/app_localizations.dart';
import 'package:bloom/services/pill_service.dart';
import 'package:bloom/screens/pill_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:bloom/services/settings_service.dart';
import 'package:bloom/services/notification_service.dart';
import 'package:bloom/services/cycle_service.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class PillScreen extends StatefulWidget {
  const PillScreen({super.key});

  @override
  State<PillScreen> createState() => _PillScreenState();
}

class _PillScreenState extends State<PillScreen> {
  final PillService _pillService = PillService();
  final SettingsService _settingsService = SettingsService();
  final CycleService _cycleService = CycleService();

  bool _isPillTrackerEnabled = false;
  TimeOfDay? _pillReminderTime;

  bool _isTakenToday = false;
  bool _isLoading = true;

  DateTime? _packStartDate;
  int _activeDays = 21;
  int _placeboDays = 7;
  Set<DateTime> _pillDays = {};

  final TextEditingController _activeDaysController = TextEditingController(text: "21");
  final TextEditingController _placeboDaysController = TextEditingController(text: "7");
  DateTime _selectedStartDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // ... (без изменений) ...
    if (!mounted) return;
    setState(() { _isLoading = true; });

    final results = await Future.wait([
      _pillService.isPillTaken(DateTime.now()),
      _settingsService.isPillTrackerEnabled(),
      _settingsService.getPillReminderTime(),
      _settingsService.getPillPackStartDate(),
      _settingsService.getPillActiveDays(),
      _settingsService.getPillPlaceboDays(),
      _pillService.getPillDays(),
    ]);

    if (mounted) {
      setState(() {
        _isTakenToday = results[0] as bool;
        _isPillTrackerEnabled = results[1] as bool;
        _pillReminderTime = results[2] as TimeOfDay?;
        _packStartDate = results[3] as DateTime?;
        _activeDays = results[4] as int;
        _placeboDays = results[5] as int;
        _pillDays = results[6] as Set<DateTime>;

        _activeDaysController.text = _activeDays.toString();
        _placeboDaysController.text = _placeboDays.toString();
        _selectedStartDate = _packStartDate ?? DateTime.now();

        _isLoading = false;
      });
    }
  }

  Future<void> _takePill() async {
    // ... (без изменений) ...
    HapticFeedback.lightImpact();
    await _pillService.savePillTaken(DateTime.now());
    _loadData();
  }

  void _openInfoScreen() {
    // ... (без изменений) ...
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PillInfoScreen()),
    );
  }

  void _onPillTrackerEnabledChanged(bool value) async {
    // ... (без изменений) ...
    setState(() { _isPillTrackerEnabled = value; });
    await _settingsService.setIsPillTrackerEnabled(value);

    if (value) {
      await _cycleService.endPeriod();
      await _cycleService.endBleeding();

      if (_pillReminderTime == null) {
        _showPillTimePicker();
      }
    } else {
      await NotificationService.cancelPillReminders();
      await _cycleService.endBleeding();
    }

    _loadData();
  }

  void _showPillTimePicker() async {
    // ... (без изменений) ...
    final l10n = AppLocalizations.of(context)!;
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _pillReminderTime ?? const TimeOfDay(hour: 21, minute: 0),
    );

    if (newTime != null) {
      setState(() { _pillReminderTime = newTime; });
      await _settingsService.setPillReminderTime(newTime);

      if (_packStartDate != null) {
        await NotificationService.schedulePillReminder(
          time: newTime,
          l10n: l10n,
          packStartDate: _packStartDate!,
          activeDays: _activeDays,
        );
      }
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    // ... (без изменений) ...
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 40)),
      lastDate: DateTime.now().add(const Duration(days: 40)),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _savePackSettings() async {
    // ... (без изменений) ...
    final int active = int.tryParse(_activeDaysController.text) ?? 21;
    final int placebo = int.tryParse(_placeboDaysController.text) ?? 7;

    await _settingsService.savePillPackSettings(_selectedStartDate, active, placebo);

    if (_pillReminderTime != null) {
      final l10n = AppLocalizations.of(context)!;
      await NotificationService.schedulePillReminder(
        time: _pillReminderTime!,
        l10n: l10n,
        packStartDate: _selectedStartDate,
        activeDays: active,
      );
    }

    _loadData();
  }

  Future<void> _showResetPackDialog() async {
    // ... (без изменений) ...
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pillResetTitle),
        content: Text(l10n.pillResetDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.pillResetButton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _settingsService.savePillPackSettings(null, _activeDays, _placeboDays);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.pillTrackerTabTitle),
        actions: [
          if (_isPillTrackerEnabled && _packStartDate != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.pillResetButton,
              onPressed: _showResetPackDialog,
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _openInfoScreen,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                  l10n.settingsPillTrackerEnable,
                  style: theme.textTheme.titleMedium
              ),
              value: _isPillTrackerEnabled,
              onChanged: _onPillTrackerEnabledChanged,
              // --- ИСПРАВЛЕНИЕ 1: Иконка ---
              secondary: Icon(Icons.medication_outlined, color: theme.colorScheme.primary),
              // ---
              controlAffinity: ListTileControlAffinity.trailing,
            ),

            const Divider(height: 32),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_isPillTrackerEnabled)
              _packStartDate == null
                  ? _buildSetupForm(l10n, theme)
                  : _buildBlisterView(l10n, theme)
            else
              _buildDisabledState(l10n, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledState(AppLocalizations l10n, ThemeData theme) {
    // ... (без изменений) ...
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
            'assets/lottie/avatar_welcome.json',
            width: 200,
            height: 200
        ),
        const SizedBox(height: 24),
        Text(
          l10n.settingsPillTrackerDesc,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSetupForm(AppLocalizations l10n, ThemeData theme) {
    // ... (без изменений) ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.pillSetupTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l10n.pillSetupDesc, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),

        Text(l10n.pillSetupStartDate, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ListTile(
          title: Text(DateFormat.yMMMd(l10n.localeName).format(_selectedStartDate)),
          trailing: const Icon(Icons.calendar_month_outlined),
          onTap: () => _selectStartDate(context),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.colorScheme.outline)
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _activeDaysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.pillSetupActiveDays,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _placeboDaysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.pillSetupPlaceboDays,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: _savePackSettings,
          child: Text(l10n.pillSetupSaveButton),
        ),
      ],
    );
  }

  Widget _buildBlisterView(AppLocalizations l10n, ThemeData theme) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final totalPills = _activeDays + _placeboDays;

    return Column(
      children: [
        ListTile(
          title: Text(l10n.settingsPillTrackerTime),
          trailing: Text(
            _pillReminderTime?.format(context) ?? l10n.settingsPillTrackerTimeNotSet,
            style: TextStyle(
              color: _pillReminderTime == null
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: _showPillTimePicker,
        ),

        GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: totalPills,
          itemBuilder: (context, index) {
            final pillDate = _packStartDate!.add(Duration(days: index));
            final isToday = isSameDay(pillDate, today);
            final isTaken = _pillDays.contains(pillDate);
            final isPlacebo = index >= _activeDays;

            return GestureDetector(
              onTap: (isToday && !_isTakenToday) ? _takePill : null,
              child: _PillCircle(
                date: pillDate,
                isToday: isToday,
                isTaken: isTaken,
                isPlacebo: isPlacebo,
              ),
            );
          },
        ),

        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: ElevatedButton.icon(
            // --- ИСПРАВЛЕНИЕ 2: Иконка ---
            icon: Icon(_isTakenToday ? Icons.check_circle : Icons.medication_outlined),
            // ---
            label: Text(
              _isTakenToday ? l10n.pillAlreadyTaken : l10n.pillTakenButton,
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: _isTakenToday
                  ? Colors.grey[400]
                  : theme.colorScheme.primary,
              foregroundColor: _isTakenToday
                  ? Colors.black87
                  : theme.colorScheme.onPrimary,
            ),
            onPressed: _isTakenToday ? null : _takePill,
          ),
        ),
      ],
    );
  }
}

/// Виджет для одного кружочка-таблетки в блистере
class _PillCircle extends StatelessWidget {
  // ... (без изменений) ...
  final DateTime date;
  final bool isToday;
  final bool isTaken;
  final bool isPlacebo;

  const _PillCircle({
    required this.date,
    required this.isToday,
    required this.isTaken,
    required this.isPlacebo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color = theme.colorScheme.surfaceVariant.withOpacity(0.5);
    Color textColor = theme.colorScheme.onSurfaceVariant;
    BoxBorder? border;

    if (isPlacebo) {
      color = theme.colorScheme.secondaryContainer.withOpacity(0.3);
      textColor = theme.colorScheme.onSecondaryContainer.withOpacity(0.5);
    }

    if (isTaken) {
      color = isPlacebo
          ? theme.colorScheme.secondaryContainer
          : theme.colorScheme.primary;
      textColor = isPlacebo
          ? theme.colorScheme.onSecondaryContainer
          : theme.colorScheme.onPrimary;
    }

    if (isToday) {
      border = Border.all(color: theme.colorScheme.primary, width: 2.5);
      textColor = theme.colorScheme.primary;
    }

    if (isToday && isTaken) {
      textColor = theme.colorScheme.onPrimary;
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}