import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';



import 'utils.dart';

void main() {
  group('AuthUtils Tests', () {
    testWidgets('isValidEmail returns true for valid email', (WidgetTester tester) async {
      bool isValid = AuthUtils.isValidEmail('test@example.com');
      print('isValidEmail returns true for valid email: $isValid');
      expect(isValid, true);
    });

    testWidgets('isValidEmail returns false for invalid email', (WidgetTester tester) async {
      bool isValid = AuthUtils.isValidEmail('invalidemail');
      print('isValidEmail returns false for invalid email: $isValid');
      expect(isValid, false);
    });

    testWidgets('isValidEmail returns false for empty email', (WidgetTester tester) async {
      bool isValid = AuthUtils.isValidEmail('');
      print('isValidEmail returns false for empty email: $isValid');
      expect(isValid, false);
    });

    testWidgets('isValidPassword returns true for valid password', (WidgetTester tester) async {
      bool isValid = AuthUtils.isValidPassword('password123');
      print('isValidPassword returns true for valid password: $isValid');
      expect(isValid, true);
    });

    testWidgets('isValidPassword returns false for invalid password', (WidgetTester tester) async {
      bool isValid = AuthUtils.isValidPassword('123');
      print('isValidPassword returns false for invalid password: $isValid');
      expect(isValid, false);
    });

    testWidgets('isValidPassword returns false for empty password', (WidgetTester tester) async {
      bool isValid = AuthUtils.isValidPassword('');
      print('isValidPassword returns false for empty password: $isValid');
      expect(isValid, false);
    });
  });

  group('ErrorUtils Tests', () {
    testWidgets('handleFirebaseAuthError displays correct error message for user-disabled', (WidgetTester tester) async {
      final error = FirebaseAuthException(code: 'user-disabled');
      String errorMessage = ErrorUtils.handleFirebaseAuthError(error);
      print('handleFirebaseAuthError displays correct error message for user-disabled: $errorMessage');
      expect(errorMessage, 'This user has been disabled. Please contact support.');
    });

    testWidgets('handleFirebaseAuthError displays correct error message for user-not-found', (WidgetTester tester) async {
      final error = FirebaseAuthException(code: 'user-not-found');
      String errorMessage = ErrorUtils.handleFirebaseAuthError(error);
      print('handleFirebaseAuthError displays correct error message for user-not-found: $errorMessage');
      expect(errorMessage, 'No user found with this email. Please sign up.');
    });

    testWidgets('handleFirebaseAuthError displays correct error message for wrong-password', (WidgetTester tester) async {
      final error = FirebaseAuthException(code: 'wrong-password');
      String errorMessage = ErrorUtils.handleFirebaseAuthError(error);
      print('handleFirebaseAuthError displays correct error message for wrong-password: $errorMessage');
      expect(errorMessage, 'Incorrect password. Please try again.');
    });

    testWidgets('handleFirebaseAuthError displays default error message for unexpected error', (WidgetTester tester) async {
      final error = Exception('Unexpected error');
      String errorMessage = ErrorUtils.handleFirebaseAuthError(error);
      print('handleFirebaseAuthError displays default error message for unexpected error: $errorMessage');
      expect(errorMessage, 'An unexpected error occurred. Please try again.');
    });
  });
}
