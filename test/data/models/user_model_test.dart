import 'package:flutter_finance/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Model Tests', () {
    test('should create User from JSON', () {
      // Arrange
      final json = {
        'username': 'brian',
        'email': 'brian@example.com',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.username, 'brian');
      expect(user.email, 'brian@example.com');
    });

    test('should convert User to JSON', () {
      // Arrange
      final user = User(
        username: 'brian',
        email: 'brian@example.com',
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['username'], 'brian');
      expect(json['email'], 'brian@example.com');
    });

    test('should create User with null email', () {
      // Act
      final user = User(username: 'testuser');

      // Assert
      expect(user.username, 'testuser');
      expect(user.email, null);
    });

    test('should create User copy with updated values', () {
      // Arrange
      final original = User(
        username: 'brian',
        email: 'brian@example.com',
      );

      // Act
      final updated = original.copyWith(email: 'newemail@example.com');

      // Assert
      expect(updated.email, 'newemail@example.com');
      expect(updated.username, 'brian');
      expect(original.email, 'brian@example.com'); // Original unchanged
    });

    test('should compare User equality correctly', () {
      // Arrange
      final user1 = User(
        username: 'brian',
        email: 'brian@example.com',
      );

      final user2 = User(
        username: 'brian',
        email: 'brian@example.com',
      );

      final user3 = User(
        username: 'different',
        email: 'brian@example.com',
      );

      // Assert
      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('should serialize to JSON without null email', () {
      // Arrange
      final user = User(username: 'testuser');

      // Act
      final json = user.toJson();

      // Assert
      expect(json.containsKey('email'), false);
      expect(json['username'], 'testuser');
    });
  });
}
