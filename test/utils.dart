// utils.dart
import 'package:firebase_auth/firebase_auth.dart';
class AuthUtils {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}

// error_utils.dart


class ErrorUtils {
  static String handleFirebaseAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return "The email address is not valid.";
        case 'user-disabled':
          return "This user has been disabled. Please contact support.";
        case 'user-not-found':
          return "No user found with this email. Please sign up.";
        case 'wrong-password':
          return "Incorrect password. Please try again.";
        default:
          return "An unexpected error occurred. Please try again.";
      }
    } else {
      return "An unexpected error occurred. Please try again.";
    }
  }
}
