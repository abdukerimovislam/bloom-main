// Файл: lib/widgets/insight_card.dart

import 'package:bloom/l10n/app_localizations.dart';
import 'package:bloom/models/cycle_phase.dart';
import 'package:flutter/material.dart';

class InsightCard extends StatelessWidget {
  final CyclePhase currentPhase;
  final Set<String> todaySymptoms;
  // --- ИЗМЕНЕНИЕ: Добавляем флаг ---
  final bool isPillTrackerEnabled;
  // ---

  const InsightCard({
    super.key,
    required this.currentPhase,
    required this.todaySymptoms,
    // --- ИЗМЕНЕНИЕ: Добавляем в конструктор ---
    required this.isPillTrackerEnabled,
    // ---
  });

  String _getInsight(AppLocalizations l10n) {

    // --- ИЗМЕНЕНИЕ: Логика для таблеток (Баг №1) ---
    if (isPillTrackerEnabled) {
      if (currentPhase == CyclePhase.menstruation) {
        // 'menstruation' - это наша симуляция "недели плацебо"
        return l10n.insightPillPlacebo;
      } else {
        // Все остальное (follicular/luteal) - это "активные таблетки"
        return l10n.insightPillActive;
      }
    }
    // ---

    // (Остальная логика для естественного цикла без изменений)
    if (currentPhase == CyclePhase.menstruation) {
      if (todaySymptoms.contains('symptomCramps')) {
        return l10n.insightMenstruation_2;
      }
      if (todaySymptoms.contains('moodSad')) {
        return l10n.insightMenstruation_3;
      }
      return l10n.insightMenstruation_1;
    }

    if (currentPhase == CyclePhase.follicular) {
      if (todaySymptoms.contains('moodHappy')) {
        return l10n.insightFollicular_3;
      }
      return l10n.insightFollicular_1;
    }

    if (currentPhase == CyclePhase.ovulation) {
      if (todaySymptoms.contains('moodHappy')) {
        return l10n.insightOvulation_1;
      }
      return l10n.insightOvulation_2;
    }

    if (currentPhase == CyclePhase.luteal) {
      if (todaySymptoms.contains('moodIrritable')) {
        return l10n.insightLuteal_1;
      }
      if (todaySymptoms.contains('symptomHeadache')) {
        return l10n.insightLuteal_3;
      }
      return l10n.insightLuteal_2;
    }

    if (currentPhase == CyclePhase.delayed) {
      return l10n.insightDelayed_1;
    }

    return l10n.insightNone;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final String insightText = _getInsight(l10n);

    // НЕ показываем, если данных нет (insightNone)
    if (insightText == l10n.insightNone) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              size: 30,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                insightText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}