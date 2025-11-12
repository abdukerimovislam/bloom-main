// Файл: lib/widgets/symptom_sheet.dart

import 'package:bloom/l10n/app_localizations.dart';
import 'package:bloom/services/symptom_service.dart';
import 'package:flutter/material.dart';
// --- ИЗМЕНЕНИЕ: Импорт Haptics ---
import 'package:flutter/services.dart';
// ---

class SymptomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const SymptomSheet({super.key, required this.selectedDate});

  @override
  State<SymptomSheet> createState() => _SymptomSheetState();
}

class _SymptomSheetState extends State<SymptomSheet> {
  final SymptomService _symptomService = SymptomService();
  Set<String> _selectedSymptoms = {};
  bool _isLoading = true;

  late TextEditingController _noteController;

  final List<String> _symptoms = ['symptomCramps', 'symptomHeadache', 'symptomNausea'];
  final List<String> _moods = ['moodHappy', 'moodSad', 'moodIrritable'];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _symptomService.getSymptoms(widget.selectedDate),
      _symptomService.getNote(widget.selectedDate),
    ]);

    if (mounted) {
      setState(() {
        _selectedSymptoms = results[0] as Set<String>;
        _noteController.text = results[1] as String;
        _isLoading = false;
      });
    }
  }

  void _toggleSymptom(String key) {
    // --- ИЗМЕНЕНИЕ: Добавляем HapticFeedback (Улучшение №2) ---
    HapticFeedback.lightImpact();
    // ---
    setState(() {
      if (_selectedSymptoms.contains(key)) {
        _selectedSymptoms.remove(key);
      } else {
        _selectedSymptoms.add(key);
      }
    });
  }

  Future<void> _saveAndClose() async {
    await Future.wait([
      _symptomService.saveSymptoms(widget.selectedDate, _selectedSymptoms),
      _symptomService.saveNote(widget.selectedDate, _noteController.text),
    ]);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    // ... (UI без изменений) ...
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      color: theme.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.symptomsTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8.0,
            children: _symptoms.map((key) {
              return FilterChip(
                label: Text(_getString(l10n, key)),
                selected: _selectedSymptoms.contains(key),
                onSelected: (selected) => _toggleSymptom(key),
                selectedColor: theme.colorScheme.primaryContainer,
                backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.4),
              );
            }).toList(),
          ),
          const Divider(height: 24),

          Wrap(
            spacing: 8.0,
            children: _moods.map((key) {
              return FilterChip(
                label: Text(_getString(l10n, key)),
                selected: _selectedSymptoms.contains(key),
                onSelected: (selected) => _toggleSymptom(key),
                selectedColor: theme.colorScheme.primaryContainer,
                backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.4),
              );
            }).toList(),
          ),
          const Divider(height: 24),

          TextField(
            controller: _noteController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.symptomNotesLabel,
              border: const OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAndClose,
              child: Text(l10n.save),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
        ],
      ),
    );
  }
}