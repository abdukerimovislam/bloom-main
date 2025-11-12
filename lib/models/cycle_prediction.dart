// Файл: lib/models/cycle_prediction.dart

class CyclePrediction {
  /// Средняя длина цикла (от 1-го дня до 1-го дня)
  final int avgCycleLength;

  /// Средняя длина самих месячных
  final int avgPeriodLength;

  // --- ИЗМЕНЕНИЕ: Добавлено новое поле ---
  /// Фактическая дата начала последнего цикла
  final DateTime lastPeriodStartDate;
  // ---

  /// Прогнозируемая дата начала следующего цикла
  final DateTime nextPeriodStartDate;

  /// Прогнозируемая дата овуляции
  final DateTime nextOvulationDate;

  /// Прогнозируемое начало фертильного окна
  final DateTime fertileWindowStart;

  /// Прогнозируемый конец фертильного окна
  final DateTime fertileWindowEnd;

  CyclePrediction({
    required this.avgCycleLength,
    required this.avgPeriodLength,
    required this.lastPeriodStartDate, // <--- Добавлено
    required this.nextPeriodStartDate,
    required this.nextOvulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
  });
}