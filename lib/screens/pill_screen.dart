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
    HapticFeedback.lightImpact();
    await _pillService.savePillTaken(DateTime.now());
    _loadData();
  }

  void _openInfoScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PillInfoScreen()),
    );
  }

  void _onPillTrackerEnabledChanged(bool value) async {
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
    final l10n = AppLocalizations.of(context)!;
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _pillReminderTime ?? const TimeOfDay(hour: 21, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 40)),
      lastDate: DateTime.now().add(const Duration(days: 40)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _savePackSettings() async {
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
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(l10n.pillResetTitle, style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        )),
        content: Text(l10n.pillResetDesc, style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.dialogCancel, style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            )),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
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
      // --- ДОБАВЛЕНИЕ: AppBar для экрана таблеток ---
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l10n.pillTrackerTabTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onBackground,
        actions: [
          if (_isPillTrackerEnabled && _packStartDate != null)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.refresh, size: 20, color: theme.colorScheme.primary),
              ),
              tooltip: l10n.pillResetButton,
              onPressed: _showResetPackDialog,
            ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
            ),
            onPressed: _openInfoScreen,
          ),
        ],
      ),

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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- УЛУЧШЕНИЕ: Карточка для переключателя ---
              Container(
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
                child: SwitchListTile(
                  title: Text(
                    l10n.settingsPillTrackerEnable,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    l10n.settingsPillTrackerDesc,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  value: _isPillTrackerEnabled,
                  onChanged: _onPillTrackerEnabledChanged,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medication_outlined, color: theme.colorScheme.primary),
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),

              const SizedBox(height: 24),

              if (_isLoading)
                Container(
                  padding: const EdgeInsets.all(40),
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
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (_isPillTrackerEnabled)
                _packStartDate == null
                    ? _buildSetupForm(l10n, theme)
                    : _buildBlisterView(l10n, theme)
              else
                _buildDisabledState(l10n, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledState(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/avatar_welcome.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.settingsPillTrackerDesc,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSetupForm(AppLocalizations l10n, ThemeData theme) {
    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.settings_outlined, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.pillSetupTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pillSetupDesc,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            l10n.pillSetupStartDate,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: Text(
              DateFormat.yMMMd(l10n.localeName).format(_selectedStartDate),
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Icon(Icons.calendar_month_outlined, color: theme.colorScheme.primary),
            onTap: () => _selectStartDate(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pillSetupActiveDays,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _activeDaysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '21',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pillSetupPlaceboDays,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _placeboDaysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '7',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _savePackSettings,
            child: Text(
              l10n.pillSetupSaveButton,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlisterView(AppLocalizations l10n, ThemeData theme) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final totalPills = _activeDays + _placeboDays;

    return Column(
      children: [
        // --- УЛУЧШЕНИЕ: Карточка для времени напоминания ---
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
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
            ),
            title: Text(
              l10n.settingsPillTrackerTime,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
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
        ),

        const SizedBox(height: 24),

        // --- УЛУЧШЕНИЕ: Карточка для блистера ---
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
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.medication_outlined, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Current Pack',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
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
            ],
          ),
        ),

        const SizedBox(height: 24),

        // --- УЛУЧШЕНИЕ: Кнопка принятия таблетки ---
        FilledButton.icon(
          icon: Icon(
            _isTakenToday ? Icons.check_circle : Icons.medication_outlined,
            size: 24,
          ),
          label: Text(
            _isTakenToday ? l10n.pillAlreadyTaken : l10n.pillTakenButton,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: _isTakenToday
                ? Colors.grey[400]
                : theme.colorScheme.primary,
            foregroundColor: _isTakenToday
                ? Colors.black87
                : theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _isTakenToday ? null : _takePill,
        ),
      ],
    );
  }
}

/// Виджет для одного кружочка-таблетки в блистере
class _PillCircle extends StatelessWidget {
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border,
        boxShadow: isToday ? [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}