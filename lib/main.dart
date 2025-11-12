// Файл: lib.main.dart

import 'package:bloom/navigation/app_router.dart';
import 'package:bloom/models/cycle_prediction.dart';
import 'package:bloom/models/cycle_phase.dart';
import 'package:bloom/screens/calendar_screen.dart';
import 'package:bloom/screens/settings_screen.dart';
import 'package:bloom/services/cycle_service.dart';
import 'package:bloom/services/settings_service.dart';
import 'package:bloom/services/notification_service.dart';
import 'package:bloom/services/symptom_service.dart';
import 'package:bloom/services/pill_service.dart';
import 'package:bloom/themes/app_themes.dart';
import 'package:bloom/widgets/cycle_avatar.dart';
import 'package:bloom/widgets/insight_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:bloom/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bloom/widgets/symptom_sheet.dart';
import 'package:bloom/screens/pill_screen.dart';

// --- ИЗМЕНЕНИЕ: Импорт Firebase ---
import 'package:firebase_core/firebase_core.dart';
// ---

void main() async {
  // --- ИЗМЕНЕНИЕ: Инициализация Firebase ---
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // <-- ВАЖНО
  // ---

  await NotificationService.initTimezones();
  await NotificationService.init();
  final cycleService = CycleService();
  final settingsService = SettingsService();

  // --- ИЗМЕНЕНИЕ: Эту логику мы перенесли в AuthGate ---
  // final bool showOnboarding = !(await cycleService.isOnboardingComplete());
  // ---

  final String? savedLocaleCode = await settingsService.getAppLocale();
  final AppTheme savedTheme = await settingsService.getAppTheme();

  runApp(MyApp(
    // --- ИЗМЕНЕНИЕ: 'showOnboarding' больше не нужен ---
    // showOnboarding: showOnboarding,
    // ---
    savedLocaleCode: savedLocaleCode,
    savedTheme: savedTheme,
  ));
}

class MyApp extends StatefulWidget {
  // --- ИЗМЕНЕНИЕ: Убрали 'showOnboarding' ---
  // final bool showOnboarding;
  // ---
  final String? savedLocaleCode;
  final AppTheme savedTheme;
  const MyApp({
    super.key,
    // required this.showOnboarding,
    this.savedLocaleCode,
    required this.savedTheme
  });
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  late AppTheme _currentTheme;
  @override
  void initState() {
    super.initState();
    if (widget.savedLocaleCode != null) {
      _locale = Locale(widget.savedLocaleCode!);
    }
    _currentTheme = widget.savedTheme;
  }
  void _setLocale(Locale newLocale) {
    setState(() { _locale = newLocale; });
  }
  void _setTheme(AppTheme newTheme) {
    setState(() { _currentTheme = newTheme; });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloom',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: AppThemes.getThemeData(_currentTheme),
      // --- ИЗМЕНЕНИЕ: initialRoute теперь AuthGate ---
      initialRoute: AppRouter.authGate,
      // ---
      onGenerateRoute: (settings) => AppRouter.generateRoute(
        settings,
        // showOnboarding: widget.showOnboarding, // <-- Больше не нужно
        onLocaleChanged: _setLocale,
        onThemeChanged: _setTheme,
      ),
    );
  }
}

// --- HomeScreen ---
class HomeScreen extends StatefulWidget {
  final Function(Locale) onLocaleChanged;
  final Function(AppTheme) onThemeChanged;
  const HomeScreen({super.key, required this.onLocaleChanged, required this.onThemeChanged});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// --- _HomeScreenState (остается БЕЗ ИЗМЕНЕНИЙ) ---
class _HomeScreenState extends State<HomeScreen> {

  bool _showStartGlow = false;
  int _currentPageIndex = 0;
  final CycleService _cycleService = CycleService();
  final SettingsService _settingsService = SettingsService();
  final SymptomService _symptomService = SymptomService();
  final PillService _pillService = PillService();

  CyclePhase _currentPhase = CyclePhase.none;
  bool _isPeriodActive = false;
  DateTime? _activePeriodStartDate;
  int _activePeriodDayCount = 0;
  bool _isPeriodDelayed = false;
  int _daysDelayed = 0;
  List<DateTime> _periodDays = [];
  CyclePrediction? _prediction;
  Set<String> _todaySymptoms = {};
  bool _isLoading = true;
  bool _isDataLoaded = false;
  int _currentCycleDay = 1;
  bool _isPillTrackerEnabled = false;
  bool _isBleedingActive = false;
  int _bleedingDayCount = 0;

  DateTime? _packStartDate;
  int _pillActiveDays = 21;
  int _pillPlaceboDays = 7;
  Set<DateTime> _pillDays = {};

  late ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_fabAnimationListener);
  }

  void _fabAnimationListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFabVisible) setState(() => _isFabVisible = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isFabVisible) setState(() => _isFabVisible = true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadData();
      _isDataLoaded = true;
    }
  }

  Future<void> _loadData() async {
    if (mounted && !_isLoading) {
      setState(() { _isLoading = true; });
    } else if (!mounted && !_isLoading) {
      _isLoading = true;
    }

    _isPeriodDelayed = false;
    _daysDelayed = 0;

    final results = await Future.wait([
      _cycleService.isPeriodActive(),
      _cycleService.getActivePeriodStart(),
      _cycleService.getPeriodDays(),
      _cycleService.getCyclePredictions(),
      _symptomService.getSymptoms(DateTime.now()),
      _settingsService.isPillTrackerEnabled(),
      _cycleService.isBleedingActive(),
      _cycleService.getActiveBleedingStart(),
      _settingsService.getPillPackStartDate(),
      _settingsService.getPillActiveDays(),
      _settingsService.getPillPlaceboDays(),
      _pillService.getPillDays(),
    ]);

    _isPeriodActive = results[0] as bool;
    _activePeriodStartDate = results[1] as DateTime?;
    _periodDays = results[2] as List<DateTime>;
    _prediction = results[3] as CyclePrediction?;
    _todaySymptoms = results[4] as Set<String>;
    _isPillTrackerEnabled = results[5] as bool;
    _isBleedingActive = results[6] as bool;
    final activeBleedingStart = results[7] as DateTime?;
    _packStartDate = results[8] as DateTime?;
    _pillActiveDays = results[9] as int;
    _pillPlaceboDays = results[10] as int;
    _pillDays = results[11] as Set<DateTime>;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (_isPeriodActive && _activePeriodStartDate != null) {
      _activePeriodDayCount = todayDate.difference(_activePeriodStartDate!).inDays + 1;
      if (_activePeriodDayCount > 7 && !_isPillTrackerEnabled) {
        await _endPeriodInternal();
        return;
      }
      final bool isTodayLogged = _periodDays.any((day) => isSameDay(day, todayDate));
      if (!isTodayLogged) {
        _periodDays.add(todayDate);
        await _cycleService.savePeriodDays(_periodDays);
        if(!_isPillTrackerEnabled) _prediction = await _cycleService.getCyclePredictions();
      }
    }

    if (_isBleedingActive && activeBleedingStart != null) {
      _bleedingDayCount = todayDate.difference(activeBleedingStart).inDays + 1;
      if (_bleedingDayCount > 7) {
        await _endBleedingInternal();
        return;
      }
      final bleedingDays = await _cycleService.getBleedingDays();
      final bool isTodayLogged = bleedingDays.any((day) => isSameDay(day, todayDate));
      if (!isTodayLogged) {
        bleedingDays.add(todayDate);
        await _cycleService.saveBleedingDays(bleedingDays);
      }
    }

    if (_isPillTrackerEnabled) {
      if (_packStartDate == null) {
        _currentPhase = CyclePhase.none;
      } else {
        final dayInPack = todayDate.difference(_packStartDate!).inDays;

        if (dayInPack < 0) {
          _currentPhase = CyclePhase.luteal;
        } else {
          final totalPackDays = _pillActiveDays + _pillPlaceboDays;
          final dayModCycle = (dayInPack % totalPackDays);

          if (dayModCycle < _pillActiveDays) {
            _currentPhase = CyclePhase.luteal;
          } else {
            _currentPhase = CyclePhase.menstruation;
          }
        }
      }
    } else {
      if (_isPeriodActive) {
        _currentPhase = CyclePhase.menstruation;
        _currentCycleDay = _activePeriodDayCount;
      } else if (_prediction != null) {
        final predictedStart = _prediction!.nextPeriodStartDate;
        final predictedStartDate = DateTime(predictedStart.year, predictedStart.month, predictedStart.day);
        final ovulationDate = DateTime(_prediction!.nextOvulationDate.year, _prediction!.nextOvulationDate.month, _prediction!.nextOvulationDate.day);

        final lastStartDate = _prediction!.lastPeriodStartDate;
        _currentCycleDay = todayDate.difference(lastStartDate).inDays + 1;

        if (todayDate.isAfter(predictedStartDate)) {
          _isPeriodDelayed = true;
          _daysDelayed = todayDate.difference(predictedStartDate).inDays;
          _currentPhase = CyclePhase.delayed;
        } else if (isSameDay(todayDate, ovulationDate)) {
          _currentPhase = CyclePhase.ovulation;
        } else if (todayDate.isAfter(ovulationDate)) {
          _currentPhase = CyclePhase.luteal;
        } else {
          _currentPhase = CyclePhase.follicular;
        }
      } else {
        _currentPhase = CyclePhase.none;
        _currentCycleDay = 1;
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scheduleNotifications();
        }
      });
    } else {
      _isLoading = false;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        print("Widget not mounted, skipping notification scheduling in _loadData");
      });
    }
  }

  Future<void> _startPeriodWithConfirmation() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.homeConfirmStartTitle),
        content: Text(l10n.homeConfirmStartDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.homeConfirmNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.homeConfirmYes),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _showStartGlow = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showStartGlow = false);
      });
      if (mounted) {
        setState(() {
          _isPeriodActive = true;
          _activePeriodStartDate = DateTime.now();
          _activePeriodDayCount = 1;
          _isPeriodDelayed = false;
          _daysDelayed = 0;
        });
      } else {
        _isPeriodActive = true;
        _activePeriodStartDate = DateTime.now();
        _activePeriodDayCount = 1;
        _isPeriodDelayed = false;
        _daysDelayed = 0;
      }
      await _cycleService.startPeriod(_activePeriodStartDate ?? DateTime.now());
      await _loadData();
    }
  }
  Future<void> _endPeriodWithConfirmation() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.homeConfirmEndTitle),
        content: Text(l10n.homeConfirmEndDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.homeConfirmNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.homeConfirmYes),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _endPeriodInternal();
    }
  }
  Future<void> _endPeriodInternal() async {
    HapticFeedback.mediumImpact();
    if (mounted) {
      setState(() {
        _isPeriodActive = false;
        _activePeriodStartDate = null;
        _activePeriodDayCount = 0;
      });
    } else {
      _isPeriodActive = false;
      _activePeriodStartDate = null;
      _activePeriodDayCount = 0;
    }
    await _cycleService.endPeriod();
    await _loadData();
  }

  Future<void> _startBleedingWithConfirmation() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logBleedingButton),
        content: Text(l10n.homeConfirmStartDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.homeConfirmNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.homeConfirmYes),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      if (mounted) {
        setState(() {
          _isBleedingActive = true;
          _bleedingDayCount = 1;
        });
      }
      await _cycleService.startBleeding(DateTime.now());
      await _loadData();
    }
  }
  Future<void> _endBleedingWithConfirmation() async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logBleedingEndButton),
        content: Text(l10n.homeConfirmEndDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.homeConfirmNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.homeConfirmYes),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _endBleedingInternal();
    }
  }
  Future<void> _endBleedingInternal() async {
    HapticFeedback.mediumImpact();
    if (mounted) {
      setState(() {
        _isBleedingActive = false;
        _bleedingDayCount = 0;
      });
    }
    await _cycleService.endBleeding();
    await _loadData();
  }

  Future<void> _scheduleNotifications() async {
    if (!mounted) return;
    final bool notificationsEnabled = await _settingsService.areNotificationsEnabled();
    if (!notificationsEnabled) {
      await NotificationService.cancelAllNotifications();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    if (_isPillTrackerEnabled) {
      await NotificationService.cancelPredictionNotifications();
    } else if (_prediction != null) {
      await NotificationService.schedulePredictionNotifications(_prediction!, l10n);
    } else {
      await NotificationService.cancelPredictionNotifications();
    }
  }

  void _onItemTapped(int index) {
    if (_currentPageIndex == 1 || _currentPageIndex == 2 || _currentPageIndex == 3) {
      _loadData();
    }
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _showSymptomSheet() {
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
            selectedDate: DateTime.now(),
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_fabAnimationListener);
    _scrollController.dispose();
    super.dispose();
  }

  String _getAppBarTitle(AppLocalizations l10n) {
    switch (_currentPageIndex) {
      case 0:
        return l10n.trackYourCycle;
      case 1:
        return l10n.calendarTitle;
      case 2:
        return "";
      case 3:
        return l10n.settingsTitle;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(l10n)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: const [],
      ),
      body: _isLoading
          ? Center(child: Lottie.asset('assets/lottie/loading_indicator.json', width: 150, height: 150,))
          : IndexedStack(
        index: _currentPageIndex,
        children: [
          _buildMainPage(),
          const CalendarScreen(),
          const PillScreen(),
          SettingsScreen(
            onLanguageChanged: widget.onLocaleChanged,
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
      floatingActionButton: _currentPageIndex == 0 ? AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isFabVisible ? 1 : 0,
          child: FloatingActionButton.extended(
            onPressed: _showSymptomSheet,
            icon: const Icon(Icons.sentiment_satisfied_alt_outlined),
            label: Text(l10n.logSymptomsButton),
          ),
        ),
      ) : null,

      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.trackYourCycle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            activeIcon: const Icon(Icons.calendar_month),
            label: l10n.calendarTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.medication_outlined),
            activeIcon: const Icon(Icons.medication),
            label: l10n.pillTrackerTabTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l10n.settingsTitle,
          ),
        ],
        currentIndex: _currentPageIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildMainPage() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            CycleAvatar(
              currentPhase: _currentPhase,
              todaySymptoms: _todaySymptoms,
            ),

            if (_isPeriodActive && !_isPillTrackerEnabled)
              _buildCycleProgressBar(l10n),

            const SizedBox(height: 20),
            InsightCard(
              currentPhase: _currentPhase,
              todaySymptoms: _todaySymptoms,
              isPillTrackerEnabled: _isPillTrackerEnabled,
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),

            if (_isPillTrackerEnabled && _packStartDate != null)
              _buildPillWeekTracker(l10n),

            if (_todaySymptoms.isNotEmpty)
              _buildTodaySymptoms(l10n),

            const SizedBox(height: 20),
            _buildPeriodStatusText(context, l10n),

            if (!_isPillTrackerEnabled)
              _buildPredictionCard(context, l10n)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 20),

            _buildPeriodButton(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleProgressBar(AppLocalizations l10n) {
    final theme = Theme.of(context);

    final totalDays = _prediction?.avgPeriodLength ?? 5;
    final currentDay = _currentCycleDay.clamp(1, totalDays);
    final double progress = currentDay / totalDays;
    final Color progressColor = theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.homeDayOfCycle(currentDay),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
              Text(
                l10n.periodLength(totalDays),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
            backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildTodaySymptoms(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _todaySymptoms.map((key) {
          return Chip(
            label: Text(_getString(l10n, key)),
            labelStyle: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.7),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          );
        }).toList(),
      ),
    );
  }

  String _getString(AppLocalizations l10n, String key) {
    switch (key) {
      case 'symptomCramps': return l10n.symptomCramps;
      case 'symptomHeadache': return l10n.symptomHeadache;
      case 'symptomNausea': return l10n.symptomNausea;
      case 'moodHappy': return l10n.moodHappy;
      case 'moodSad': return l10n.moodSad;
      case 'moodIrritable': return l10n.moodIrritable;
      default: return key;
    }
  }

  Widget _buildPeriodButton(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Widget buttonContent;

    if (_isPillTrackerEnabled) {
      if (_isBleedingActive) {
        buttonContent = ElevatedButton.icon(
          icon: const Icon(Icons.stop_circle_outlined),
          label: Text(l10n.logBleedingEndButton, style: const TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.grey[400],
            foregroundColor: Colors.black87,
          ),
          onPressed: _endBleedingWithConfirmation,
        );
      } else {
        buttonContent = ElevatedButton.icon(
          icon: const Icon(Icons.play_circle_outlined),
          label: Text(l10n.logBleedingButton, style: const TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: _startBleedingWithConfirmation,
        );
      }
    }
    else {
      if (_isPeriodActive) {
        buttonContent = ElevatedButton.icon(
          icon: const Icon(Icons.stop_circle_outlined),
          label: Text(l10n.logPeriodEndButton, style: const TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.grey[400],
            foregroundColor: Colors.black87,
          ),
          onPressed: _endPeriodWithConfirmation,
        );
      } else {
        buttonContent = ElevatedButton.icon(
          icon: const Icon(Icons.play_circle_outlined),
          label: Text(l10n.logPeriodStartButton, style: const TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: _startPeriodWithConfirmation,
        );
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (!_isPeriodActive && !_isBleedingActive)
          IgnorePointer(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.5),
              ),
            )
                .animate(target: _showStartGlow ? 1 : 0)
                .scaleXY(
              begin: 0.5,
              end: 3.0,
              duration: 800.ms,
              curve: Curves.easeOutExpo,
            )
                .then(delay: 100.ms)
                .fadeOut(
              begin: 1.0,
              duration: 800.ms,
              curve: Curves.easeOutExpo,
            ),
          ),
        buttonContent,
      ],
    );
  }

  Widget _buildPeriodStatusText(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    if (_isBleedingActive) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          l10n.homeBleedingDay(_bleedingDayCount),
          style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_isPeriodActive) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          l10n.periodIsActive(_activePeriodDayCount),
          style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_isPeriodDelayed && _daysDelayed > 0 && !_isPillTrackerEnabled) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          l10n.periodDelayed(_daysDelayed),
          style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_currentPhase == CyclePhase.none && !_isPillTrackerEnabled) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Lottie.asset(
              'assets/lottie/avatar_welcome.json',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.homeEmptyDesc,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPredictionCard(BuildContext context, AppLocalizations l10n) {
    if (_currentPhase != CyclePhase.follicular &&
        _currentPhase != CyclePhase.ovulation &&
        _currentPhase != CyclePhase.luteal) {
      return const SizedBox.shrink();
    }
    final prediction = _prediction;
    final DateFormat formatter = DateFormat.MMMd(l10n.localeName);
    if (prediction != null) {

      final daysUntilNextPeriod = prediction.nextPeriodStartDate.difference(DateTime.now()).inDays;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.predictionsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.nextPeriodPrediction(daysUntilNextPeriod > 0 ? daysUntilNextPeriod : 0),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(l10n.nextPeriodDate(formatter.format(prediction.nextPeriodStartDate))),
              const Divider(height: 24),
              Text(
                l10n.fertileWindow,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "${formatter.format(prediction.fertileWindowStart)} - ${formatter.format(prediction.fertileWindowEnd)}",
              ),
              Text(
                "${l10n.ovulation}: ${formatter.format(prediction.nextOvulationDate)}",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.cycleLength(prediction.avgCycleLength)),
                  Text(l10n.periodLength(prediction.avgPeriodLength)),
                ],
              )
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPillWeekTracker(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final int dayInPack = today.difference(_packStartDate!).inDays;

    int startOfWeekIndex;
    if (dayInPack < 0) {
      startOfWeekIndex = 0;
    } else {
      startOfWeekIndex = (dayInPack / 7).floor() * 7;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final int currentPillIndex = startOfWeekIndex + index;
          if (currentPillIndex >= (_pillActiveDays + _pillPlaceboDays)) {
            return const SizedBox(width: 40);
          }

          final pillDate = _packStartDate!.add(Duration(days: currentPillIndex));
          final isToday = isSameDay(pillDate, today);
          final isTaken = _pillDays.contains(pillDate);
          final isPlacebo = currentPillIndex >= _pillActiveDays;

          return _PillCircle(
            date: pillDate,
            isToday: isToday,
            isTaken: isTaken,
            isPlacebo: isPlacebo,
          );
        }),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildLastPeriodText(BuildContext context, AppLocalizations l10n) {
    return const SizedBox.shrink();
  }
}

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

    return Container(
      width: 40,
      height: 40,
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