// Файл: lib/screens/pill_info_screen.dart

import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PillInfoScreen extends StatelessWidget {
  const PillInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pillInfoTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoSection(
              title: l10n.pillInfoWhatAreThey,
              body: l10n.pillInfoWhatAreTheyBody,
            ),
            const SizedBox(height: 24),
            _InfoSection(
              title: l10n.pillInfoHowToUse,
              body: l10n.pillInfoHowToUseBody,
            ),
            const SizedBox(height: 24),
            _InfoSection(
              title: l10n.pillInfoWhatIfMissed,
              body: l10n.pillInfoWhatIfMissedBody,
              isWarning: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String body;
  final bool isWarning;

  const _InfoSection({
    required this.title,
    required this.body,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: isWarning ? theme.colorScheme.error : theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5, // Увеличиваем межстрочный интервал
          ),
        ),
      ],
    );
  }
}