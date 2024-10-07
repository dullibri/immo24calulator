import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter für den aktuellen Benutzer
  User? get currentUser => _auth.currentUser;

  // Methode zum Überprüfen, ob ein Benutzer angemeldet ist
  bool get isSignedIn => currentUser != null;

  // auth change user stream
  Stream<User?> get user => _auth.authStateChanges();

  // sign in with email & password
  Future<String?> signIn(String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('Sign in successful');
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? 'An unknown error occurred.';
      }
    } catch (e) {
      print('Unexpected error during sign in: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // register with email & password
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.code} - ${e.message}');
      return e.message;
    }
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.code} - ${e.message}');
      return e.message;
    }
  }
}
