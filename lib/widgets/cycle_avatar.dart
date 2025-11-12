// Файл: lib/widgets/cycle_avatar.dart

import 'package:bloom/models/cycle_phase.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CycleAvatar extends StatelessWidget {
  final CyclePhase currentPhase;
  // --- ИЗМЕНЕНИЕ: Добавляем симптомы ---
  final Set<String> todaySymptoms;
  // ---

  const CycleAvatar({
    super.key,
    required this.currentPhase,
    // --- ИЗМЕНЕНИЕ: Добавляем в конструктор ---
    required this.todaySymptoms,
    // ---
  });

  // --- ИЗМЕНЕНИЕ: Логика аватара теперь знает о симптомах ---
  String _getAnimationPath() {

    // 1. Приоритет симптомов (эмпатия)
    if (todaySymptoms.contains('moodSad') || todaySymptoms.contains('symptomCramps')) {
      return 'assets/lottie/avatar_sad.json'; //
    }
    if (todaySymptoms.contains('symptomHeadache') || todaySymptoms.contains('symptomNausea')) {
      return 'assets/lottie/avatar_sleep.json'; //
    }

    // 2. Логика по фазам (если нет сильных симптомов)
    switch (currentPhase) {
      case CyclePhase.menstruation:
        return 'assets/lottie/avatar_sleep.json'; //
      case CyclePhase.follicular:
        return 'assets/lottie/avatar_follicular.json'; //
      case CyclePhase.ovulation:
        return 'assets/lottie/avatar_ovulation.json'; //
      case CyclePhase.luteal:
        return 'assets/lottie/avatar_luteal.json'; //
      case CyclePhase.delayed:
        return 'assets/lottie/avatar_delayed.json'; //
      case CyclePhase.none:
      default:
        return 'assets/lottie/avatar_default.json'; //
    }
  }
  // ---

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      _getAnimationPath(),
      width: 250,
      height: 250,
      fit: BoxFit.contain,
    );
  }
}