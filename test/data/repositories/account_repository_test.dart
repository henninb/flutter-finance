import 'package:dio/dio.dart';
import 'package:flutter_finance/data/models/account_model.dart';
import 'package:flutter_finance/data/repositories/account_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'account_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late AccountRepository accountRepository;

  setUp(() {
    mockDio = MockDio();
    accountRepository = AccountRepository(mockDio);
  });

  group('AccountRepository Tests', () {
    test('fetchAccounts should return list of accounts', () async {
      // Arrange
      final responseData = [
        {
          'accountId': 1,
          'accountNameOwner': 'chase_brian',
          'accountType': 'credit',
          'activeStatus': true,
          'moniker': 'Chase Visa',
          'cleared': 500.0,
          'outstanding': 500.0,
          'future': 0.0,
        },
        {
          'accountId': 2,
          'accountNameOwner': 'wells_fargo_brian',
          'accountType': 'checking',
          'activeStatus': true,
          'moniker': 'Wells Fargo Checking',
          'cleared': 2000.0,
          'outstanding': 0.0,
          'future': 0.0,
        },
      ];

      when(mockDio.get('/account/active')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/account/active'),
          statusCode: 200,
          data: responseData,
        ),
      );

      // Act
      final result = await accountRepository.fetchAccounts();

      // Assert
      expect(result, isA<List<Account>>());
      expect(result.length, 2);
      expect(result[0].accountNameOwner, 'chase_brian');
      expect(result[1].accountNameOwner, 'wells_fargo_brian');
      verify(mockDio.get('/account/active')).called(1);
    });

    test('createAccount should return created account', () async {
      // Arrange
      final account = Account(
        accountNameOwner: 'test_account',
        accountType: 'checking',
        moniker: 'Test Account',
      );

      final responseData = {
        'accountId': 3,
        'accountNameOwner': 'test_account',
        'accountType': 'checking',
        'activeStatus': true,
        'moniker': 'Test Account',
        'cleared': 0.0,
        'outstanding': 0.0,
        'future': 0.0,
      };

      when(
        mockDio.post(
          '/account',
          data: anyNamed('data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/account'),
          statusCode: 201,
          data: responseData,
        ),
      );

      // Act
      final result = await accountRepository.createAccount(account);

      // Assert
      expect(result, isA<Account>());
      expect(result.accountId, 3);
      expect(result.accountNameOwner, 'test_account');
      verify(
        mockDio.post('/account', data: anyNamed('data')),
      ).called(1);
    });

    test('updateAccount should return updated account', () async {
      // Arrange
      final account = Account(
        accountId: 1,
        accountNameOwner: 'chase_brian',
        accountType: 'credit',
        moniker: 'Updated Moniker',
      );

      final responseData = {
        'accountId': 1,
        'accountNameOwner': 'chase_brian',
        'accountType': 'credit',
        'activeStatus': true,
        'moniker': 'Updated Moniker',
        'cleared': 500.0,
        'outstanding': 500.0,
        'future': 0.0,
      };

      when(
        mockDio.put(
          '/account',
          data: anyNamed('data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/account'),
          statusCode: 200,
          data: responseData,
        ),
      );

      // Act
      final result = await accountRepository.updateAccount(account);

      // Assert
      expect(result, isA<Account>());
      expect(result.moniker, 'Updated Moniker');
      verify(
        mockDio.put('/account', data: anyNamed('data')),
      ).called(1);
    });

    test('deleteAccount should complete successfully', () async {
      // Arrange
      when(mockDio.delete('/account/chase_brian')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/account/chase_brian'),
          statusCode: 200,
        ),
      );

      // Act
      await accountRepository.deleteAccount('chase_brian');

      // Assert
      verify(mockDio.delete('/account/chase_brian')).called(1);
    });

    test('fetchAccounts should throw exception on error', () async {
      // Arrange
      when(mockDio.get('/account/active')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/account/active'),
          response: Response(
            requestOptions: RequestOptions(path: '/account/active'),
            statusCode: 500,
            data: {'error': 'Server error'},
          ),
        ),
      );

      // Act & Assert
      expect(
        () => accountRepository.fetchAccounts(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
