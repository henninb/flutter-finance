import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../providers/transaction_provider.dart';

class TransactionTotalsCard extends ConsumerWidget {
  final String accountNameOwner;

  const TransactionTotalsCard({
    super.key,
    required this.accountNameOwner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalsAsync = ref.watch(transactionTotalsProvider(accountNameOwner));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: totalsAsync.when(
          data: (totals) => _buildTotalsContent(context, totals),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Failed to load totals',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalsContent(BuildContext context, Map<String, double> totals) {
    final total = totals['totals'] ?? 0.0;
    final cleared = totals['totalsCleared'] ?? 0.0;
    final outstanding = totals['totalsOutstanding'] ?? 0.0;
    final future = totals['totalsFuture'] ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Balance',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.formatCurrency(total),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: total >= 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),

        // Breakdown - all in one row
        Row(
          children: [
            Expanded(
              child: _buildTotalItem(
                context,
                label: 'Cleared',
                amount: cleared,
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTotalItem(
                context,
                label: 'Outstanding',
                amount: outstanding,
                icon: Icons.pending_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildTotalItem(
                context,
                label: 'Future',
                amount: future,
                icon: Icons.schedule_outlined,
                color: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalItem(
    BuildContext context, {
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.formatCurrency(amount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: amount >= 0 ? color : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
