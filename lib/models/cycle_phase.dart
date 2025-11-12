// Файл: lib/models/cycle_phase.dart

enum CyclePhase {
  menstruation, // Цикл активен
  follicular,   // После цикла, до овуляции
  ovulation,    // Овуляция
  luteal,       // После овуляции, до цикла (ПМС)
  delayed,      // Задержка
  none          // Нет данных
}