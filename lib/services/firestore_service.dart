// Файл: lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Получает ссылку на документ пользователя
  /// 'users/{uid}'
  DocumentReference? get _userDoc {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid);
  }

  /// Получает ссылку на под-коллекцию данных пользователя
  /// 'users/{uid}/data/{docName}'
  DocumentReference? _dataDoc(String docName) {
    final doc = _userDoc;
    if (doc == null) return null;
    return doc.collection('data').doc(docName);
  }

  // --- 1. Настройки (Settings) ---

  /// Сохраняет ОДИН документ со всеми настройками
  Future<void> saveSettings(Map<String, dynamic> data) async {
    final doc = _dataDoc('settings');
    if (doc == null) return;
    // SetOptions(merge: true) не перезапишет, а ОБНОВИТ
    // (например, если мы меняем только тему, язык не затрется)
    await doc.set(data, SetOptions(merge: true));
  }

  /// Загружает документ со всеми настройками
  Future<Map<String, dynamic>?> loadSettings() async {
    final doc = _dataDoc('settings');
    if (doc == null) return null;

    final snapshot = await doc.get();
    if (!snapshot.exists) return null;

    return snapshot.data() as Map<String, dynamic>;
  }

  // --- 2. Онбординг ---

  /// Устанавливает флаг, что онбординг пройден
  Future<void> setOnboardingCompleteInCloud() async {
    if (_userDoc == null) return;
    await _userDoc!.set({
      'onboardingComplete': true
    }, SetOptions(merge: true));
  }

  /// Проверяет, пройден ли онбординг (в облаке)
  Future<bool> isOnboardingCompleteInCloud() async {
    if (_userDoc == null) return false;
    final snapshot = await _userDoc!.get();
    if (!snapshot.exists) return false;

    final data = snapshot.data() as Map<String, dynamic>?;
    return data?['onboardingComplete'] ?? false;
  }
}