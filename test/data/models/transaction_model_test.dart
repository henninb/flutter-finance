import 'package:flutter_finance/data/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Transaction Model Tests', () {
    test('should create Transaction from JSON', () {
      // Arrange
      final json = {
        'guid': '123e4567-e89b-12d3-a456-426614174000',
        'accountNameOwner': 'chase_brian',
        'accountType': 'credit',
        'transactionDate': '2021-01-01T00:00:00.000Z',
        'description': 'Grocery Store',
        'category': 'groceries',
        'amount': 50.75,
        'transactionState': 'cleared',
        'transactionType': 'expense',
        'reoccurringType': 'onetime',
        'activeStatus': true,
        'notes': 'Weekly shopping',
      };

      // Act
      final transaction = Transaction.fromJson(json);

      // Assert
      expect(transaction.guid, '123e4567-e89b-12d3-a456-426614174000');
      expect(transaction.accountNameOwner, 'chase_brian');
      expect(transaction.description, 'Grocery Store');
      expect(transaction.category, 'groceries');
      expect(transaction.amount, 50.75);
      expect(transaction.transactionState, 'cleared');
      expect(transaction.notes, 'Weekly shopping');
    });

    test('should convert Transaction to JSON', () {
      // Arrange
      final transaction = Transaction(
        guid: '123e4567-e89b-12d3-a456-426614174000',
        accountNameOwner: 'chase_brian',
        accountType: 'credit',
        transactionDate: DateTime.parse('2021-01-01T00:00:00.000Z'),
        description: 'Grocery Store',
        category: 'groceries',
        amount: 50.75,
        transactionState: 'cleared',
        notes: 'Weekly shopping',
      );

      // Act
      final json = transaction.toJson();

      // Assert
      expect(json['guid'], '123e4567-e89b-12d3-a456-426614174000');
      expect(json['description'], 'Grocery Store');
      expect(json['amount'], 50.75);
      expect(json['category'], 'groceries');
      expect(json['transactionState'], 'cleared');
    });

    test('should create Transaction with default values', () {
      // Act
      final transaction = Transaction(
        guid: 'test-guid',
        accountNameOwner: 'test_account',
        accountType: 'checking',
        transactionDate: DateTime.now(),
        description: 'Test',
        category: 'test',
        amount: 100.0,
        transactionState: 'cleared',
      );

      // Assert
      expect(transaction.activeStatus, true);
      expect(transaction.notes, '');
      expect(transaction.transactionType, 'expense');
      expect(transaction.reoccurringType, 'onetime');
    });

    test('should create Transaction copy with updated values', () {
      // Arrange
      final original = Transaction(
        guid: 'test-guid',
        accountNameOwner: 'test_account',
        accountType: 'checking',
        transactionDate: DateTime.now(),
        description: 'Original',
        category: 'test',
        amount: 100.0,
        transactionState: 'outstanding',
      );

      // Act
      final updated = original.copyWith(
        description: 'Updated',
        amount: 200.0,
      );

      // Assert
      expect(updated.description, 'Updated');
      expect(updated.amount, 200.0);
      expect(updated.guid, original.guid);
      expect(original.description, 'Original'); // Original unchanged
    });

    test('should compare Transaction equality correctly', () {
      // Arrange
      final date = DateTime.now();
      final transaction1 = Transaction(
        guid: 'test-guid',
        accountNameOwner: 'test_account',
        accountType: 'checking',
        transactionDate: date,
        description: 'Test',
        category: 'test',
        amount: 100.0,
        transactionState: 'cleared',
      );

      final transaction2 = Transaction(
        guid: 'test-guid',
        accountNameOwner: 'test_account',
        accountType: 'checking',
        transactionDate: date,
        description: 'Test',
        category: 'test',
        amount: 100.0,
        transactionState: 'cleared',
      );

      final transaction3 = Transaction(
        guid: 'different-guid',
        accountNameOwner: 'test_account',
        accountType: 'checking',
        transactionDate: date,
        description: 'Test',
        category: 'test',
        amount: 100.0,
        transactionState: 'cleared',
      );

      // Assert
      expect(transaction1, equals(transaction2));
      expect(transaction1, isNot(equals(transaction3)));
    });
  });
}
