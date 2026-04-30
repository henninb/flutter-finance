import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

/// Logger instance
final _logger = Logger();

/// Transactions state with pagination support
class TransactionsState extends Equatable {
  final List<Transaction> allTransactions;
  final int currentPage;
  final int pageSize;
  final bool isLoading;
  final String? errorMessage;

  const TransactionsState({
    this.allTransactions = const [],
    this.currentPage = 0,
    this.pageSize = 50,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Get transactions for current page
  List<Transaction> get paginatedTransactions {
    final startIndex = currentPage * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, allTransactions.length);

    if (startIndex >= allTransactions.length) {
      return [];
    }

    return allTransactions.sublist(startIndex, endIndex);
  }

  /// Get total number of pages
  int get totalPages {
    if (allTransactions.isEmpty) return 1;
    return (allTransactions.length / pageSize).ceil();
  }

  /// Check if there's a next page
  bool get hasNextPage => currentPage < totalPages - 1;

  /// Check if there's a previous page
  bool get hasPreviousPage => currentPage > 0;

  TransactionsState copyWith({
    List<Transaction>? allTransactions,
    int? currentPage,
    int? pageSize,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TransactionsState(
      allTransactions: allTransactions ?? this.allTransactions,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    allTransactions,
    currentPage,
    pageSize,
    isLoading,
    errorMessage,
  ];
}

/// Transaction list state notifier for a specific account
class TransactionsNotifier extends Notifier<TransactionsState> {
  final String accountNameOwner;
  late TransactionRepository _repository;

  TransactionsNotifier(this.accountNameOwner);

  @override
  TransactionsState build() {
    _repository = ref.watch(transactionRepositoryProvider);
    Future.microtask(fetchTransactions);
    return const TransactionsState(isLoading: true);
  }

  /// Fetch all transactions for the account
  Future<void> fetchTransactions() async {
    _logger.i(
      '📊 TransactionsNotifier: Fetching transactions for $accountNameOwner',
    );
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final transactions = await _repository.fetchTransactionsByAccount(
        accountNameOwner,
      );
      _logger.i(
        '✅ TransactionsNotifier: Loaded ${transactions.length} transactions',
      );

      // Sort transactions by date, newest first
      final sortedTransactions = List<Transaction>.from(transactions)
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      state = state.copyWith(
        allTransactions: sortedTransactions,
        isLoading: false,
        currentPage: 0, // Reset to first page when fetching
      );
    } catch (e) {
      _logger.e('❌ TransactionsNotifier: Error loading transactions: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Go to next page
  void nextPage() {
    if (state.hasNextPage) {
      _logger.i(
        '📄 TransactionsNotifier: Going to page ${state.currentPage + 1}',
      );
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  /// Go to previous page
  void previousPage() {
    if (state.hasPreviousPage) {
      _logger.i(
        '📄 TransactionsNotifier: Going to page ${state.currentPage - 1}',
      );
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 0 && page < state.totalPages) {
      _logger.i('📄 TransactionsNotifier: Going to page $page');
      state = state.copyWith(currentPage: page);
    }
  }

  /// Add new transaction
  Future<void> addTransaction(Transaction transaction) async {
    _logger.i(
      '➕ TransactionsNotifier: Adding transaction: ${transaction.description}',
    );

    try {
      await _repository.createTransaction(transaction);
      _logger.i('✅ TransactionsNotifier: Transaction created, refreshing list');
      await fetchTransactions();
    } catch (e) {
      _logger.e('❌ TransactionsNotifier: Failed to add transaction: $e');
      rethrow;
    }
  }

  /// Update existing transaction
  Future<void> updateTransaction(Transaction transaction) async {
    _logger.i(
      '✏️ TransactionsNotifier: Updating transaction ${transaction.guid}',
    );

    try {
      await _repository.updateTransaction(transaction);
      _logger.i('✅ TransactionsNotifier: Transaction updated, refreshing list');
      await fetchTransactions();
    } catch (e) {
      _logger.e('❌ TransactionsNotifier: Failed to update transaction: $e');
      rethrow;
    }
  }

  /// Delete transaction
  Future<void> deleteTransaction(String guid) async {
    _logger.i('🗑️ TransactionsNotifier: Deleting transaction $guid');

    try {
      await _repository.deleteTransaction(guid);
      _logger.i('✅ TransactionsNotifier: Transaction deleted, refreshing list');
      await fetchTransactions();
    } catch (e) {
      _logger.e('❌ TransactionsNotifier: Failed to delete transaction: $e');
      rethrow;
    }
  }

  /// Update transaction state
  Future<void> updateTransactionState(String guid, String newState) async {
    _logger.i(
      '🔄 TransactionsNotifier: Updating transaction $guid state to $newState',
    );

    try {
      await _repository.updateTransactionState(guid, newState);
      _logger.i(
        '✅ TransactionsNotifier: Transaction state updated, refreshing list',
      );
      await fetchTransactions();
    } catch (e) {
      _logger.e(
        '❌ TransactionsNotifier: Failed to update transaction state: $e',
      );
      rethrow;
    }
  }

  /// Refresh transactions (for pull-to-refresh)
  Future<void> refresh() async {
    _logger.i('🔄 TransactionsNotifier: Refreshing transactions');
    await fetchTransactions();
  }
}

/// Provider family for transactions by account
final transactionsProvider = NotifierProvider.family<
  TransactionsNotifier,
  TransactionsState,
  String
>((accountNameOwner) => TransactionsNotifier(accountNameOwner));

/// Provider family for transaction totals by account
final transactionTotalsProvider =
    FutureProvider.family<Map<String, double>, String>((
      ref,
      accountNameOwner,
    ) async {
      _logger.i(
        '💰 TransactionTotalsProvider: Fetching totals for $accountNameOwner',
      );
      final repository = ref.watch(transactionRepositoryProvider);
      return await repository.fetchAccountTotals(accountNameOwner);
    });
