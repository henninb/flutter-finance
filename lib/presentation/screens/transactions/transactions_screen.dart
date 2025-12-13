import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_totals_card.dart';
import '../../widgets/add_transaction_dialog.dart';
import '../../widgets/edit_transaction_dialog.dart';

class TransactionsScreen extends ConsumerWidget {
  final Account account;

  const TransactionsScreen({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsProvider(account.accountNameOwner));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Formatters.formatAccountName(account.accountNameOwner)),
            Text(
              account.accountType.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(transactionsProvider(account.accountNameOwner).notifier).refresh();
          ref.invalidate(transactionTotalsProvider(account.accountNameOwner));
        },
        child: transactionsState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : transactionsState.errorMessage != null
                ? _buildErrorView(context, ref, transactionsState.errorMessage!)
                : _buildTransactionsList(context, ref, transactionsState),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTransactionDialog(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    WidgetRef ref,
    transactionsState,
  ) {
    final paginatedTransactions = transactionsState.paginatedTransactions;
    final allTransactions = transactionsState.allTransactions;

    if (allTransactions.isEmpty) {
      return ListView(
        children: [
          TransactionTotalsCard(accountNameOwner: account.accountNameOwner),
          _buildEmptyState(context),
        ],
      );
    }

    return Column(
      children: [
        // Transactions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: paginatedTransactions.length + 1, // +1 for totals card
            itemBuilder: (context, index) {
              if (index == 0) {
                return TransactionTotalsCard(accountNameOwner: account.accountNameOwner);
              }

              final transaction = paginatedTransactions[index - 1];
              return _buildTransactionCard(context, ref, transaction);
            },
          ),
        ),
        // Pagination controls
        _buildPaginationControls(context, ref, transactionsState),
      ],
    );
  }

  Widget _buildPaginationControls(
    BuildContext context,
    WidgetRef ref,
    transactionsState,
  ) {
    final currentPage = transactionsState.currentPage;
    final totalPages = transactionsState.totalPages;
    final hasNextPage = transactionsState.hasNextPage;
    final hasPreviousPage = transactionsState.hasPreviousPage;
    final startIndex = currentPage * transactionsState.pageSize + 1;
    final endIndex = ((currentPage + 1) * transactionsState.pageSize)
        .clamp(0, transactionsState.allTransactions.length);
    final totalTransactions = transactionsState.allTransactions.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundPaper,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page info
          Text(
            'Showing $startIndex-$endIndex of $totalTransactions transactions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              IconButton(
                onPressed: hasPreviousPage
                    ? () => ref.read(transactionsProvider(account.accountNameOwner).notifier).previousPage()
                    : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous page',
              ),
              const SizedBox(width: 16),
              // Page indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Page ${currentPage + 1} of $totalPages',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              // Next button
              IconButton(
                onPressed: hasNextPage
                    ? () => ref.read(transactionsProvider(account.accountNameOwner).notifier).nextPage()
                    : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next page',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) {
    final stateColor = _getStateColor(transaction.transactionState);
    final isCredit = transaction.accountType == 'credit';
    final displayAmount = isCredit ? -transaction.amount : transaction.amount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: stateColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTransactionIcon(transaction.category),
            color: stateColor,
          ),
        ),
        title: Text(
          transaction.description,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              transaction.category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  Formatters.formatDateDisplay(transaction.transactionDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    Formatters.formatTransactionState(transaction.transactionState),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: stateColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          Formatters.formatCurrency(displayAmount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: displayAmount >= 0 ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
        ),
        onTap: () => _showEditTransactionDialog(context, ref, transaction),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(transactionsProvider(account.accountNameOwner).notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'cleared':
        return AppColors.success;
      case 'outstanding':
        return AppColors.warning;
      case 'future':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTransactionIcon(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_bag;
      case 'groceries':
      case 'food':
        return Icons.restaurant;
      case 'entertainment':
        return Icons.movie;
      case 'transportation':
      case 'gas':
        return Icons.local_gas_station;
      case 'utilities':
        return Icons.lightbulb;
      case 'healthcare':
        return Icons.local_hospital;
      case 'income':
      case 'salary':
        return Icons.account_balance_wallet;
      case 'bills':
        return Icons.receipt;
      default:
        return Icons.attach_money;
    }
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(account: account),
    );
  }

  void _showEditTransactionDialog(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditTransactionDialog(
        transaction: transaction,
        accountNameOwner: account.accountNameOwner,
      ),
    );
  }
}
