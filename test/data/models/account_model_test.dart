import 'package:flutter_finance/data/models/account_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Account Model Tests', () {
    test('should create Account from JSON', () {
      // Arrange
      final json = {
        'accountId': 1,
        'accountNameOwner': 'chase_brian',
        'accountType': 'credit',
        'activeStatus': true,
        'moniker': 'Chase Visa',
        'cleared': 500.25,
        'outstanding': 500.25,
        'future': 0.0,
      };

      // Act
      final account = Account.fromJson(json);

      // Assert
      expect(account.accountId, 1);
      expect(account.accountNameOwner, 'chase_brian');
      expect(account.accountType, 'credit');
      expect(account.activeStatus, true);
      expect(account.moniker, 'Chase Visa');
      expect(account.cleared, 500.25);
      expect(account.outstanding, 500.25);
      expect(account.future, 0.0);
    });

    test('should convert Account to JSON', () {
      // Arrange
      final account = Account(
        accountId: 1,
        accountNameOwner: 'chase_brian',
        accountType: 'credit',
        activeStatus: true,
        moniker: 'Chase Visa',
        cleared: 500.25,
        outstanding: 500.25,
        future: 0.0,
      );

      // Act
      final json = account.toJson();

      // Assert
      expect(json['accountId'], 1);
      expect(json['accountNameOwner'], 'chase_brian');
      expect(json['accountType'], 'credit');
      expect(json['cleared'], 500.25);
    });

    test('should create Account with default values', () {
      // Act
      final account = Account(
        accountNameOwner: 'test_account',
        accountType: 'checking',
      );

      // Assert
      expect(account.accountId, null);
      expect(account.activeStatus, true);
      expect(account.cleared, 0.0);
      expect(account.outstanding, 0.0);
      expect(account.future, 0.0);
    });

    test('should calculate total correctly', () {
      // Arrange
      final account = Account(
        accountNameOwner: 'test_account',
        accountType: 'checking',
        cleared: 100.0,
        outstanding: 50.0,
        future: 25.0,
      );

      // Act
      final total = account.total;

      // Assert
      expect(total, 175.0);
    });

    test('should create Account copy with updated values', () {
      // Arrange
      final original = Account(
        accountId: 1,
        accountNameOwner: 'chase_brian',
        accountType: 'credit',
        cleared: 500.0,
      );

      // Act
      final updated = original.copyWith(cleared: 600.0);

      // Assert
      expect(updated.accountId, 1);
      expect(updated.accountNameOwner, 'chase_brian');
      expect(updated.cleared, 600.0);
      expect(original.cleared, 500.0); // Original unchanged
    });

    test('should compare Account equality correctly', () {
      // Arrange
      final account1 = Account(
        accountId: 1,
        accountNameOwner: 'chase_brian',
        accountType: 'credit',
      );

      final account2 = Account(
        accountId: 1,
        accountNameOwner: 'chase_brian',
        accountType: 'credit',
      );

      final account3 = Account(
        accountId: 2,
        accountNameOwner: 'chase_brian',
        accountType: 'credit',
      );

      // Assert
      expect(account1, equals(account2));
      expect(account1, isNot(equals(account3)));
    });
  });
}
