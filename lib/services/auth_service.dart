import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  /// Самый стабильный поток
  Stream<User?> get authStateChanges => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  bool isAnonymous() => _auth.currentUser?.isAnonymous ?? false;

  // -------------------------------------------------
  // EMAIL LOGIN / SIGNUP
  // -------------------------------------------------

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Если захочешь — можно включить подтверждение email
      // await _auth.currentUser?.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
  }

  // -------------------------------------------------
  // GOOGLE SIGN IN
  // -------------------------------------------------

  Future<String?> signInWithGoogle() async {
    try {
      // Чистим прошлую сессию Google (фикс ошибки "ongoing sign in")
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}

      // Запускаем Google Sign In
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();
      if (googleUser == null) return "Sign in cancelled";

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      return e.toString();
    }
  }

  // -------------------------------------------------
  // ANONYMOUS LOGIN
  // -------------------------------------------------

  Future<String?> signInAnonymously() async {
    try {
      if (_auth.currentUser != null) return null;

      await _auth.signInAnonymously();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
  }

  // -------------------------------------------------
  // LINK GOOGLE TO ANONYMOUS ACCOUNT
  // -------------------------------------------------

  Future<String?> linkGoogleAccount() async {
    try {
      final user = _auth.currentUser;

      if (user == null || !user.isAnonymous) {
        return "Only anonymous users can link accounts.";
      }

      // Начинаем Google вход
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google sign in aborted";

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 🔗 Пытаемся привязать Google к гостю
      await user.linkWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {

      // ---------------------------------------------
      // 🎯 Уникальная обработка конфликта:
      // Google already linked to ANOTHER account
      // ---------------------------------------------
      if (e.code == 'credential-already-in-use') {
        try {
          // 1. Входим в существующий Google аккаунт
          final googleUserCredential =
          await _auth.signInWithCredential(GoogleAuthProvider.credential(
            accessToken: (await _googleSignIn.currentUser?.authentication)?.accessToken,
            idToken: (await _googleSignIn.currentUser?.authentication)?.idToken,
          ));

          // 2. Успешно вошли → значит нужно удалить старого гостя
          await _auth.currentUser?.delete();

          return null;
        } catch (e2) {
          return "Failed to sign in to existing Google account: $e2";
        }
      }

      return e.message;
    } catch (e) {
      return e.toString();
    }
  }


  // -------------------------------------------------
  // SIGN OUT
  // -------------------------------------------------

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}

    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // -------------------------------------------------
  // ERROR MAPPER
  // -------------------------------------------------

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "User not found.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'email-already-in-use':
        return "Email already exists.";
      case 'weak-password':
        return "Password is too weak.";
      case 'invalid-email':
        return "Invalid email address.";
      case 'credential-already-in-use':
        return "This Google account is already linked.";
      case 'requires-recent-login':
        return "Please login again and retry.";
      default:
        return e.message ?? e.code;
    }
  }
}
