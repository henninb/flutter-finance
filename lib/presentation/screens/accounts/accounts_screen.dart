import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/account_model.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/account_card.dart';
import '../../widgets/account_totals_card.dart';
import '../transactions/transactions_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(accountsProvider.notifier).refresh();
          ref.invalidate(accountTotalsProvider);
        },
        child: accountsAsync.when(
          data: (accounts) => _buildAccountsList(
            context,
            ref,
            accounts,
            authState.user?.username,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorView(context, ref, error),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add account screen
          _showAddAccountDialog(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
      ),
    );
  }

  Widget _buildAccountsList(
    BuildContext context,
    WidgetRef ref,
    List<Account> accounts,
    String? username,
  ) {
    if (accounts.isEmpty) {
      return _buildEmptyState(context);
    }

    final searchQuery = ref.watch(accountSearchQueryProvider);
    final filteredAccounts = _filterAccounts(accounts, searchQuery);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount:
          filteredAccounts.length +
          2, // +1 for totals card, +1 for search field
      itemBuilder: (context, index) {
        if (index == 0) {
          return const AccountTotalsCard();
        }

        if (index == 1) {
          return _buildSearchField(context, ref);
        }

        final account = filteredAccounts[index - 2];
        return AccountCard(
          account: account,
          onTap: () {
            // Navigate to account details/transactions
            _showAccountDetails(context, account);
          },
          onEdit: () {
            _showEditAccountDialog(context, ref, account);
          },
          onDelete: () {
            _showDeleteConfirmation(context, ref, account);
          },
        );
      },
    );
  }

  List<Account> _filterAccounts(List<Account> accounts, String query) {
    if (query.isEmpty) {
      return accounts;
    }

    final lowercaseQuery = query.toLowerCase();
    return accounts.where((account) {
      return account.accountNameOwner.toLowerCase().contains(lowercaseQuery) ||
          account.accountType.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Widget _buildSearchField(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(accountSearchQueryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        onChanged: (value) {
          ref.read(accountSearchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search accounts...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    ref.read(accountSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.backgroundPaper,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Accounts Yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first account',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load accounts',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(accountsProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Add Account coming soon!')));
  }

  void _showEditAccountDialog(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${account.accountNameOwner} coming soon!')),
    );
  }

  void _showAccountDetails(BuildContext context, Account account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionsScreen(account: account),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "${account.accountNameOwner}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(accountsProvider.notifier)
                    .deleteAccount(account.accountNameOwner);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete account: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
