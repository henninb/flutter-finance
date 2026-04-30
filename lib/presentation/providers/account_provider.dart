import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';

/// Logger instance
final _logger = Logger();

/// Account list state notifier
class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() async {
    _logger.i('📊 AccountsNotifier: Fetching accounts');
    final accounts =
        await ref.watch(accountRepositoryProvider).fetchAccounts();
    _logger.i('✅ AccountsNotifier: Loaded ${accounts.length} accounts');
    return accounts;
  }

  /// Fetch all accounts (manual refresh)
  Future<void> fetchAccounts() async {
    _logger.i('📊 AccountsNotifier: Fetching accounts');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final accounts =
          await ref.read(accountRepositoryProvider).fetchAccounts();
      _logger.i('✅ AccountsNotifier: Loaded ${accounts.length} accounts');
      return accounts;
    });
    if (state.hasError) {
      _logger.e(
        '❌ AccountsNotifier: Error loading accounts: ${state.error}',
      );
    }
  }

  /// Add new account
  Future<void> addAccount(Account account) async {
    _logger.i(
      '➕ AccountsNotifier: Adding account: ${account.accountNameOwner}',
    );

    try {
      await ref.read(accountRepositoryProvider).createAccount(account);
      _logger.i('✅ AccountsNotifier: Account created, refreshing list');
      await fetchAccounts();
    } catch (e) {
      _logger.e('❌ AccountsNotifier: Failed to add account: $e');
      rethrow;
    }
  }

  /// Update existing account
  Future<void> updateAccount(Account account) async {
    _logger.i('✏️ AccountsNotifier: Updating account ${account.accountId}');

    try {
      await ref.read(accountRepositoryProvider).updateAccount(account);
      _logger.i('✅ AccountsNotifier: Account updated, refreshing list');
      await fetchAccounts();
    } catch (e) {
      _logger.e('❌ AccountsNotifier: Failed to update account: $e');
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount(String accountNameOwner) async {
    _logger.i('🗑️ AccountsNotifier: Deleting account $accountNameOwner');

    try {
      await ref.read(accountRepositoryProvider).deleteAccount(accountNameOwner);
      _logger.i('✅ AccountsNotifier: Account deleted, refreshing list');
      await fetchAccounts();
    } catch (e) {
      _logger.e('❌ AccountsNotifier: Failed to delete account: $e');
      rethrow;
    }
  }

  /// Refresh accounts (for pull-to-refresh)
  Future<void> refresh() async {
    _logger.i('🔄 AccountsNotifier: Refreshing accounts');
    await fetchAccounts();
  }
}

/// Provider for accounts list
final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<Account>>(AccountsNotifier.new);

/// Provider for account totals — recomputes whenever accounts are mutated
final accountTotalsProvider = FutureProvider<Map<String, double>>((ref) async {
  _logger.i('💰 AccountTotalsProvider: Fetching totals');
  ref.watch(accountsProvider);
  final repository = ref.watch(accountRepositoryProvider);
  return await repository.fetchTotals();
});

/// Provider to get accounts by type (debit/credit)
final accountsByTypeProvider = Provider.family<List<Account>, String>((
  ref,
  accountType,
) {
  final accountsAsync = ref.watch(accountsProvider);

  return accountsAsync.when(
    data: (accounts) {
      final filtered = accounts
          .where((a) => a.accountType == accountType)
          .toList();
      _logger.d('📊 Filtered ${filtered.length} $accountType accounts');
      return filtered;
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});

/// Provider to get active accounts only
final activeAccountsProvider = Provider<List<Account>>((ref) {
  final accountsAsync = ref.watch(accountsProvider);

  return accountsAsync.when(
    data: (accounts) {
      final active = accounts.where((a) => a.activeStatus).toList();
      _logger.d('📊 Filtered ${active.length} active accounts');
      return active;
    },
    loading: () => [],
    error: (error, stack) => [],
  );
});

/// Simple notifier for the account search query
class _SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

/// Provider for account search query
final accountSearchQueryProvider =
    NotifierProvider<_SearchQueryNotifier, String>(_SearchQueryNotifier.new);
