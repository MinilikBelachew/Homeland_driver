import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {
  @override
  final User user = MockUser();
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'testUid';

  @override
  String? get email => 'test@example.com';
}

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockDatabaseEvent extends Mock implements DatabaseEvent {
  @override
  final DataSnapshot snapshot = MockDataSnapshot();
}

class MockDataSnapshot extends Mock implements DataSnapshot {
  @override
  dynamic get value => {'key': 'value'};
}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
