// Файл: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Получает ID текущего пользователя
  String? get _uid {
    return _auth.currentUser?.uid;
  }

  /// Возвращает ссылку на документ текущего пользователя
  DocumentReference? get _userDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  // --- Методы для SettingsService ---

  /// Загружает все настройки из документа пользователя
  Future<Map<String, dynamic>?> loadSettings() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.get();
    return snapshot.data() as Map<String, dynamic>?;
  }

  /// Сохраняет (обновляет) настройки в документе пользователя
  Future<void> saveSettings(Map<String, dynamic> data) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.set(data, SetOptions(merge: true));
  }

  // --- Методы для AuthGate и Onboarding ---

  /// Проверяет, пройден ли онбординг (в облаке)
  Future<bool> isOnboardingCompleteInCloud() async {
    final doc = _userDoc;
    if (doc == null) return false;

    final snapshot = await doc.get();
    if (!snapshot.exists) return false;

    final data = snapshot.data() as Map<String, dynamic>?;
    return data?['onboardingComplete'] ?? false;
  }

  // ---
  // --- НОВЫЙ МЕТОД ДЛЯ ОНБОРДИНГА ---
  // ---

  /// Устанавливает флаг 'onboardingComplete' в true в Firestore
  Future<void> setOnboardingCompleteInCloud() async {
    final doc = _userDoc;
    if (doc == null) return;

    print("☁️ Firestore: Установка onboardingComplete = true");
    await doc.set({
      'onboardingComplete': true
    }, SetOptions(merge: true));
  }

  // ---
  // --- МЕТОДЫ ДЛЯ СИНХРОНИЗАЦИИ ДАННЫХ ---
  // ---

  /// (Для CycleService)
  /// Загружает данные цикла из подколлекции 'data'
  Future<Map<String, dynamic>?> getUserCycleData() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.collection('data').doc('cycle').get();
    return snapshot.data();
  }

  /// (Для PillService)
  /// Загружает данные о таблетках из подколлекции 'data'
  Future<Map<String, dynamic>?> getUserPillData() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.collection('data').doc('pills').get();
    return snapshot.data();
  }

  /// (Для SymptomService - Симптомы)
  /// Загружает данные о симптомах из подколлекции 'data'
  Future<Map<String, dynamic>?> getUserSymptomData() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.collection('data').doc('symptoms').get();
    return snapshot.data();
  }

  // ---
  // --- НОВЫЙ МЕТОД ДЛЯ ЗАМЕТОК ---
  // ---

  /// (Для SymptomService - Заметки)
  /// Загружает данные о заметках из подколлекции 'data'
  Future<Map<String, dynamic>?> getUserNoteData() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.collection('data').doc('notes').get();
    return snapshot.data();
  }
}