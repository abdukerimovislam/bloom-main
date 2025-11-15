// Файл: lib/screens/onboarding_screen.dart

import 'package:bloom/services/cycle_service.dart';
import 'package:flutter/material.dart';
import 'package:bloom/l10n/app_localizations.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:numberpicker/numberpicker.dart';

// --- ИЗМЕНЕНИЕ: Убран AppRouter ---
// import '../navigation/app_router.dart';

import 'package:bloom/services/firestore_service.dart';
import 'package:bloom/services/settings_service.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(Locale) onLocaleChanged;

  // --- ИЗМЕНЕНИЕ: Новый коллбэк ---
  final VoidCallback onOnboardingComplete;
  // ---

  const OnboardingScreen({
    super.key,
    required this.onLocaleChanged,
    required this.onOnboardingComplete, // <-- Добавлено
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final CycleService _cycleService = CycleService();
  final SettingsService _settingsService = SettingsService();
  final FirestoreService _firestoreService = FirestoreService();

  int _avgCycleLength = 28;
  int _avgPeriodLength = 5;
  DateTime? _lastPeriodStart;

  void _onDone() async {
    // 1. Сохраняем настройки в SettingsService
    await _settingsService.saveManualAvgCycleLength(_avgCycleLength);
    await _settingsService.saveManualAvgPeriodLength(_avgPeriodLength);

    // 2. Сохраняем дни цикла в CycleService
    if (_lastPeriodStart != null) {
      final daysToSave = List.generate(
          _avgPeriodLength,
              (index) => _lastPeriodStart!.add(Duration(days: index))
      );
      await _cycleService.savePeriodDays(daysToSave);
      // TODO: Бэкап этих дней в Firestore
    }

    // 3. Отмечаем онбординг пройденным (в Firestore)
    await _firestoreService.setOnboardingCompleteInCloud();

    // ---
    // --- ИСПРАВЛЕНИЕ: Вызываем коллбэк вместо навигации ---
    // ---
    if (mounted) {
      widget.onOnboardingComplete();
    }
  }

  Future<void> _pickLastPeriodDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _lastPeriodStart = date;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final baseTextStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 19.0, color: Colors.black54);
    final titleTextStyle = Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black87);

    final pageDecoration = PageDecoration(
      titleTextStyle: titleTextStyle,
      bodyTextStyle: baseTextStyle,
      bodyPadding: const EdgeInsets.all(16.0),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: l10n.welcomeTitle,
          body: l10n.welcomeDesc,
          image: Center(
            child: Lottie.asset(
              'assets/lottie/avatar_welcome.json',
              width: 250,
              height: 250,
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: l10n.questionPeriodTitle,
          body: l10n.questionPeriodDesc,
          footer: ElevatedButton(
            onPressed: () => _pickLastPeriodDate(context),
            child: Text(
                _lastPeriodStart == null
                    ? l10n.pickADate
                    : "${_lastPeriodStart!.day}.${_lastPeriodStart!.month}.${_lastPeriodStart!.year}"
            ),
          ),
          image: Center(
            child: Lottie.asset(
              'assets/lottie/avatar_follicular.json',
              width: 250,
              height: 250,
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: l10n.questionPeriodLengthTitle,
          body: l10n.questionPeriodLengthDesc,
          footer: NumberPicker(
            value: _avgPeriodLength,
            minValue: 2,
            maxValue: 10,
            step: 1,
            axis: Axis.horizontal,
            onChanged: (value) {
              setState(() {
                _avgPeriodLength = value;
              });
            },
          ),
          image: Center(
            child: Lottie.asset(
              'assets/lottie/avatar_sleep.json',
              width: 250,
              height: 250,
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: l10n.questionLengthTitle,
          body: l10n.questionLengthDesc,
          footer: NumberPicker(
            value: _avgCycleLength,
            minValue: 15,
            maxValue: 45,
            step: 1,
            axis: Axis.horizontal,
            onChanged: (value) {
              setState(() {
                _avgCycleLength = value;
              });
            },
          ),
          image: Center(
            child: Lottie.asset(
              'assets/lottie/avatar_luteal.json',
              width: 250,
              height: 250,
            ),
          ),
          decoration: pageDecoration,
        ),
      ],

      onDone: _onDone,
      onSkip: _onDone,
      showSkipButton: true,
      skip: Text(l10n.skip, style: const TextStyle(fontWeight: FontWeight.bold)),
      next: const Icon(Icons.arrow_forward),
      done: Text(l10n.done, style: const TextStyle(fontWeight: FontWeight.bold)),

      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.grey,
        activeColor: Colors.pinkAccent,
        activeSize: const Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}