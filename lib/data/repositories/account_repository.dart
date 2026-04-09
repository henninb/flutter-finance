import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../data_sources/remote/dio_provider.dart';
import '../models/account_model.dart';
import '../../core/utils/formatters.dart';

/// Logger instance
final _logger = Logger();

/// Repository for account-related API calls
class AccountRepository {
  final Dio _dio;

  AccountRepository(this._dio);

  /// Fetch all accounts
  Future<List<Account>> fetchAccounts() async {
    _logger.i('📊 AccountRepository: Fetching all accounts');

    try {
      final response = await _dio.get('/account/active');
      _logger.d('📥 AccountRepository: Response: ${response.data}');

      if (response.data is List) {
        final accounts = (response.data as List)
            .map((json) => Account.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('✅ AccountRepository: Fetched ${accounts.length} accounts');
        return accounts;
      }

      _logger.e('❌ AccountRepository: Invalid response format');
      throw Exception('Invalid response format for accounts');
    } on DioException catch (e) {
      _logger.e('❌ AccountRepository: Failed to fetch accounts');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to fetch accounts: ${e.message}');
    } catch (e) {
      _logger.e('❌ AccountRepository: Unexpected error: $e');
      throw Exception('Failed to fetch accounts: $e');
    }
  }

  /// Fetch single account by name
  Future<Account> fetchAccountByName(String accountNameOwner) async {
    _logger.i('📊 AccountRepository: Fetching account $accountNameOwner');

    try {
      final response = await _dio.get('/account/$accountNameOwner');
      _logger.d('📥 AccountRepository: Response: ${response.data}');

      final account = Account.fromJson(response.data as Map<String, dynamic>);
      _logger.i(
        '✅ AccountRepository: Fetched account: ${account.accountNameOwner}',
      );

      return account;
    } on DioException catch (e) {
      _logger.e(
        '❌ AccountRepository: Failed to fetch account $accountNameOwner',
      );
      _logger.e('   Status code: ${e.response?.statusCode}');
      throw Exception('Failed to fetch account: ${e.message}');
    } catch (e) {
      _logger.e('❌ AccountRepository: Unexpected error: $e');
      throw Exception('Failed to fetch account: $e');
    }
  }

  /// Create new account
  Future<Account> createAccount(Account account) async {
    _logger.i(
      '➕ AccountRepository: Creating account: ${account.accountNameOwner}',
    );

    try {
      final response = await _dio.post('/account', data: account.toJson());

      _logger.d('📥 AccountRepository: Response: ${response.data}');

      final createdAccount = Account.fromJson(
        response.data as Map<String, dynamic>,
      );
      _logger.i(
        '✅ AccountRepository: Account created with ID: ${createdAccount.accountId}',
      );

      return createdAccount;
    } on DioException catch (e) {
      _logger.e('❌ AccountRepository: Failed to create account');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to create account: ${e.message}');
    } catch (e) {
      _logger.e('❌ AccountRepository: Unexpected error: $e');
      throw Exception('Failed to create account: $e');
    }
  }

  /// Update existing account
  Future<Account> updateAccount(Account account) async {
    _logger.i(
      '✏️ AccountRepository: Updating account ${account.accountNameOwner}',
    );

    try {
      final response = await _dio.put(
        '/account/${account.accountNameOwner}',
        data: account.toJson(),
      );

      _logger.d('📥 AccountRepository: Response: ${response.data}');

      final updatedAccount = Account.fromJson(
        response.data as Map<String, dynamic>,
      );
      _logger.i(
        '✅ AccountRepository: Account updated: ${updatedAccount.accountNameOwner}',
      );

      return updatedAccount;
    } on DioException catch (e) {
      _logger.e('❌ AccountRepository: Failed to update account');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to update account: ${e.message}');
    } catch (e) {
      _logger.e('❌ AccountRepository: Unexpected error: $e');
      throw Exception('Failed to update account: $e');
    }
  }

  /// Delete account by name
  Future<void> deleteAccount(String accountNameOwner) async {
    _logger.i('🗑️ AccountRepository: Deleting account $accountNameOwner');

    try {
      await _dio.delete('/account/$accountNameOwner');
      _logger.i('✅ AccountRepository: Account deleted successfully');
    } on DioException catch (e) {
      _logger.e('❌ AccountRepository: Failed to delete account');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to delete account: ${e.message}');
    } catch (e) {
      _logger.e('❌ AccountRepository: Unexpected error: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Fetch account totals
  Future<Map<String, double>> fetchTotals() async {
    _logger.i('💰 AccountRepository: Fetching account totals');

    try {
      final response = await _dio.get('/account/totals');
      _logger.d('📥 AccountRepository: Response: ${response.data}');

      final totals = {
        'totals': Formatters.parseDouble(response.data['totals']),
        'totalsCleared': Formatters.parseDouble(response.data['totalsCleared']),
        'totalsOutstanding': Formatters.parseDouble(response.data['totalsOutstanding']),
        'totalsFuture': Formatters.parseDouble(response.data['totalsFuture']),
      };

      _logger.i(
        '✅ AccountRepository: Fetched totals - Total: \$${totals['totals']}',
      );
      return totals;
    } on DioException catch (e) {
      _logger.e('❌ AccountRepository: Failed to fetch totals');
      _logger.e('   Status code: ${e.response?.statusCode}');
      throw Exception('Failed to fetch totals: ${e.message}');
    } catch (e) {
      _logger.e('❌ AccountRepository: Unexpected error: $e');
      throw Exception('Failed to fetch totals: $e');
    }
  }
}

/// Provider for AccountRepository
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AccountRepository(dio);
});
