// Файл: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
// --- ИЗМЕНЕНИЕ: Импорт Google Sign In ---
import 'package:google_sign_in/google_sign_in.dart';
// ---

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // --- ИЗМЕНЕНИЕ: Добавляем GoogleSignIn ---
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // ---

  /// Поток, который слушает состояние (вход/выход)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Получить текущего пользователя
  User? get currentUser => _auth.currentUser;

  // --- ИЗМЕНЕНИЕ: Проверка на "Инкогнито" ---
  /// Проверяет, является ли текущий пользователь анонимным
  bool isAnonymous() {
    return _auth.currentUser?.isAnonymous ?? false;
  }
  // ---

  /// Вход по Email
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Успех
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Регистрация по Email
  Future<String?> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Успех
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // --- ИЗМЕНЕНИЕ: Новый метод (Google) ---
  /// Вход через Google
  Future<String?> signInWithGoogle() async {
    try {
      // 1. Запрос Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google sign in aborted"; // Пользователь отменил

      // 2. Получение auth деталей
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Создание учетных данных Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Вход в Firebase
      await _auth.signInWithCredential(credential);
      return null; // Успех
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
  // ---

  // --- ИЗМЕНЕНИЕ: Новый метод (Инкогнито) ---
  /// Вход "Инкогнито" (Анонимно)
  Future<String?> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      return null; // Успех
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
  // ---

  // --- ИЗМЕНЕНИЕ: Новый метод (Привязка) ---
  /// Привязывает Google аккаунт к текущему Анонимному
  Future<String?> linkGoogleAccount() async {
    try {
      if (_auth.currentUser == null || !_auth.currentUser!.isAnonymous) {
        return "Only anonymous users can link accounts.";
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google sign in aborted";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Привязка (link) вместо входа (signIn)
      await _auth.currentUser!.linkWithCredential(credential);
      return null; // Успех
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        return 'This Google account is already linked to another user.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
  // ---

  /// Выход
  Future<void> signOut() async {
    // --- ИЗМЕНЕНИЕ: Нужно также выйти из Google ---
    await _googleSignIn.signOut();
    await _auth.signOut();
    // ---
  }
}