import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../data_sources/remote/dio_provider.dart';
import '../models/transaction_model.dart';
import '../../core/utils/formatters.dart';

/// Logger instance
final _logger = Logger();

/// Repository for transaction-related API calls
class TransactionRepository {
  final Dio _dio;

  TransactionRepository(this._dio);

  /// Fetch all transactions for an account
  Future<List<Transaction>> fetchTransactionsByAccount(
    String accountNameOwner,
  ) async {
    if (accountNameOwner.trim().isEmpty) {
      throw ArgumentError('accountNameOwner must not be empty');
    }
    _logger.i(
      '📊 TransactionRepository: Fetching transactions for $accountNameOwner',
    );

    try {
      final response = await _dio.get(
        '/transaction/account/select/$accountNameOwner',
      );
      _logger.d('📥 TransactionRepository: Response: ${response.data}');

      if (response.data is List) {
        final transactions = (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map(Transaction.fromJson)
            .toList();

        _logger.i(
          '✅ TransactionRepository: Fetched ${transactions.length} transactions',
        );
        return transactions;
      }

      _logger.e('❌ TransactionRepository: Invalid response format');
      throw Exception('Invalid response format for transactions');
    } on DioException catch (e) {
      _logger.e('❌ TransactionRepository: Failed to fetch transactions');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to fetch transactions: ${e.message}');
    } catch (e) {
      _logger.e('❌ TransactionRepository: Unexpected error: $e');
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  /// Fetch transaction by GUID
  Future<Transaction> fetchTransactionByGuid(String guid) async {
    if (guid.trim().isEmpty) throw ArgumentError('guid must not be empty');
    _logger.i('📊 TransactionRepository: Fetching transaction $guid');

    try {
      final response = await _dio.get('/transaction/$guid');
      _logger.d('📥 TransactionRepository: Response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format for transaction');
      }
      final transaction = Transaction.fromJson(
        response.data as Map<String, dynamic>,
      );
      _logger.i(
        '✅ TransactionRepository: Fetched transaction: ${transaction.description}',
      );

      return transaction;
    } on DioException catch (e) {
      _logger.e('❌ TransactionRepository: Failed to fetch transaction $guid');
      _logger.e('   Status code: ${e.response?.statusCode}');
      throw Exception('Failed to fetch transaction: ${e.message}');
    } catch (e) {
      _logger.e('❌ TransactionRepository: Unexpected error: $e');
      throw Exception('Failed to fetch transaction: $e');
    }
  }

  /// Create new transaction
  Future<Transaction> createTransaction(Transaction transaction) async {
    _logger.i(
      '➕ TransactionRepository: Creating transaction: ${transaction.description}',
    );

    try {
      final response = await _dio.post(
        '/transaction',
        data: transaction.toJson(),
      );

      _logger.d('📥 TransactionRepository: Response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format for created transaction');
      }
      final createdTransaction = Transaction.fromJson(
        response.data as Map<String, dynamic>,
      );
      _logger.i(
        '✅ TransactionRepository: Transaction created with ID: ${createdTransaction.transactionId}',
      );

      return createdTransaction;
    } on DioException catch (e) {
      _logger.e('❌ TransactionRepository: Failed to create transaction');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to create transaction: ${e.message}');
    } catch (e) {
      _logger.e('❌ TransactionRepository: Unexpected error: $e');
      throw Exception('Failed to create transaction: $e');
    }
  }

  /// Update existing transaction
  Future<Transaction> updateTransaction(Transaction transaction) async {
    _logger.i(
      '✏️ TransactionRepository: Updating transaction ${transaction.guid}',
    );

    try {
      final response = await _dio.put(
        '/transaction/${transaction.guid}',
        data: transaction.toJson(),
      );

      _logger.d('📥 TransactionRepository: Response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format for updated transaction');
      }
      final updatedTransaction = Transaction.fromJson(
        response.data as Map<String, dynamic>,
      );
      _logger.i(
        '✅ TransactionRepository: Transaction updated: ${updatedTransaction.description}',
      );

      return updatedTransaction;
    } on DioException catch (e) {
      _logger.e('❌ TransactionRepository: Failed to update transaction');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to update transaction: ${e.message}');
    } catch (e) {
      _logger.e('❌ TransactionRepository: Unexpected error: $e');
      throw Exception('Failed to update transaction: $e');
    }
  }

  /// Delete transaction by GUID
  Future<void> deleteTransaction(String guid) async {
    if (guid.trim().isEmpty) throw ArgumentError('guid must not be empty');
    _logger.i('🗑️ TransactionRepository: Deleting transaction $guid');

    try {
      await _dio.delete('/transaction/$guid');
      _logger.i('✅ TransactionRepository: Transaction deleted successfully');
    } on DioException catch (e) {
      _logger.e('❌ TransactionRepository: Failed to delete transaction');
      _logger.e('   Status code: ${e.response?.statusCode}');
      _logger.e('   Response data: ${e.response?.data}');
      throw Exception('Failed to delete transaction: ${e.message}');
    } catch (e) {
      _logger.e('❌ TransactionRepository: Unexpected error: $e');
      throw Exception('Failed to delete transaction: $e');
    }
  }

  /// Update transaction state
  Future<Transaction> updateTransactionState(String guid, String state) async {
    if (guid.trim().isEmpty) throw ArgumentError('guid must not be empty');
    if (state.trim().isEmpty) throw ArgumentError('state must not be empty');
    _logger.i(
      '🔄 TransactionRepository: Updating transaction $guid state to $state',
    );

    try {
      final response = await _dio.put('/transaction/state/update/$guid/$state');
      _logger.d('📥 TransactionRepository: Response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format for transaction state update');
      }
      final updatedTransaction = Transaction.fromJson(
        response.data as Map<String, dynamic>,
      );
      _logger.i('✅ TransactionRepository: Transaction state updated');

      return updatedTransaction;
    } on DioException catch (e) {
      _logger.e('❌ TransactionRepository: Failed to update transaction state');
      _logger.e('   Status code: ${e.response?.statusCode}');
      throw Exception('Failed to update transaction state: ${e.message}');
    } catch (e) {
      _logger.e('❌ TransactionRepository: Unexpected error: $e');
      throw Exception('Failed to update transaction state: $e');
    }
  }

  /// Generate a new UUID for transaction
  Future<String> generateUuid() async {
    _logger.i('🆔 TransactionRepository: Generating UUID');

    try {
      final response = await _dio.post('/uuid/generate');
      _logger.d('📥 TransactionRepository: Response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format for UUID');
      }
      final uuid = (response.data as Map<String, dynamic>)['uuid'] as String?;
      if (uuid == null || uuid.isEmpty) {
        throw Exception('Server returned empty UUID');
      }
      _logger.i('✅ TransactionRepository: Generated UUID: $uuid');

      return uuid;
    } on DioException catch (e) {
      _logger.e('❌ TransactionRepository: Failed to generate UUID');
      _logger.e('   Status code: ${e.response?.statusCode}');
      throw Exception('Failed to generate UUID: ${e.message}');
    } catch (e) {
      _logger.e('❌ TransactionRepository: Unexpected error: $e');
      throw Exception('Failed to generate UUID: $e');
    }
  }

  /// Fetch transaction totals for an account
  Future<Map<String, double>> fetchAccountTotals(
    String accountNameOwner,
  ) async {
    if (accountNameOwner.trim().isEmpty) {
      throw ArgumentError('accountNameOwner must not be empty');
    }
    _logger.i(
      '💰 TransactionRepository: Fetching totals for $accountNameOwner',
    );

    try {
      final response = await _dio.get(
        '/transaction/account/totals/$accountNameOwner',
      );
      _logger.d('📥 TransactionRepository: Response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format for account totals');
      }
      final data = response.data as Map<String, dynamic>;
      final totals = {
        'totals': Formatters.parseDouble(data['totals']),
        'totalsCleared': Formatters.parseDouble(data['totalsCleared']),
        'totalsOutstanding': Formatters.parseDouble(data['totalsOutstanding']),
        'totalsFuture': Formatters.parseDouble(data['totalsFuture']),
      };

      _logger.i(
        '✅ TransactionRepository: Fetched totals - Total: \$${totals['totals']}',
      );
      return totals;
    } on DioException catch (e) {
      _logger.e('❌ TransactionRepository: Failed to fetch totals');
      _logger.e('   Status code: ${e.response?.statusCode}');
      throw Exception('Failed to fetch totals: ${e.message}');
    } catch (e) {
      _logger.e('❌ TransactionRepository: Unexpected error: $e');
      throw Exception('Failed to fetch totals: $e');
    }
  }
}

/// Provider for TransactionRepository
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TransactionRepository(dio);
});
