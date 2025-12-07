import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class EditTransactionDialog extends ConsumerStatefulWidget {
  final Transaction transaction;
  final String accountNameOwner;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
    required this.accountNameOwner,
  });

  @override
  ConsumerState<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends ConsumerState<EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late DateTime _selectedDate;
  late String _transactionState;
  late String _transactionType;
  bool _isSubmitting = false;

  // Common transaction categories
  final List<String> _categories = [
    'groceries',
    'shopping',
    'food',
    'entertainment',
    'transportation',
    'gas',
    'utilities',
    'healthcare',
    'income',
    'salary',
    'bills',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill all fields with existing transaction data
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _categoryController = TextEditingController(text: widget.transaction.category);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _notesController = TextEditingController(text: widget.transaction.notes);
    _selectedDate = widget.transaction.transactionDate;

    // Validate transaction state - default to 'outstanding' if invalid
    final validStates = ['cleared', 'outstanding', 'future'];
    _transactionState = validStates.contains(widget.transaction.transactionState.toLowerCase())
        ? widget.transaction.transactionState.toLowerCase()
        : 'outstanding';

    // Validate transaction type - default to 'expense' if invalid
    final validTypes = ['expense', 'income'];
    _transactionType = validTypes.contains(widget.transaction.transactionType.toLowerCase())
        ? widget.transaction.transactionType.toLowerCase()
        : 'expense';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create updated transaction with same guid
      final updatedTransaction = widget.transaction.copyWith(
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim().toLowerCase(),
        amount: double.parse(_amountController.text),
        transactionDate: _selectedDate,
        transactionState: _transactionState,
        transactionType: _transactionType,
        notes: _notesController.text.trim(),
      );

      // Update transaction
      await ref
          .read(transactionsProvider(widget.accountNameOwner).notifier)
          .updateTransaction(updatedTransaction);

      // Invalidate totals to refresh them
      ref.invalidate(transactionTotalsProvider(widget.accountNameOwner));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update transaction: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Icons.edit,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Transaction',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            widget.accountNameOwner,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    prefixIcon: Icon(Icons.description),
                    hintText: 'e.g., Amazon purchase',
                  ),
                  enabled: !_isSubmitting,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category field with autocomplete
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: _categoryController.text),
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _categories;
                    }
                    return _categories.where((category) =>
                        category.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (value) {
                    _categoryController.text = value;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    _categoryController.text = controller.text;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category),
                        hintText: 'Select or type category',
                      ),
                      enabled: !_isSubmitting,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount *',
                    prefixIcon: Icon(Icons.attach_money),
                    hintText: '0.00',
                  ),
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d{0,2}')),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Transaction type dropdown
                DropdownButtonFormField<String>(
                  value: _transactionType,
                  decoration: const InputDecoration(
                    labelText: 'Type *',
                    prefixIcon: Icon(Icons.swap_vert),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                  ],
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _transactionType = value;
                            });
                          }
                        },
                ),
                const SizedBox(height: 16),

                // Date picker
                InkWell(
                  onTap: _isSubmitting ? null : () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      Formatters.formatDateDisplay(_selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Transaction state dropdown
                DropdownButtonFormField<String>(
                  value: _transactionState,
                  decoration: const InputDecoration(
                    labelText: 'State *',
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cleared', child: Text('Cleared')),
                    DropdownMenuItem(value: 'outstanding', child: Text('Outstanding')),
                    DropdownMenuItem(value: 'future', child: Text('Future')),
                  ],
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _transactionState = value;
                            });
                          }
                        },
                ),
                const SizedBox(height: 16),

                // Notes field
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.note),
                    hintText: 'Additional details',
                  ),
                  enabled: !_isSubmitting,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
                const SizedBox(height: 12),

                // Delete button
                OutlinedButton(
                  onPressed: _isSubmitting ? null : () => _showDeleteConfirmation(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Delete Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete "${widget.transaction.description}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close confirmation dialog
              try {
                await ref
                    .read(transactionsProvider(widget.accountNameOwner).notifier)
                    .deleteTransaction(widget.transaction.guid);

                // Invalidate totals to refresh them
                ref.invalidate(transactionTotalsProvider(widget.accountNameOwner));

                if (mounted) {
                  Navigator.pop(context); // Close edit dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete transaction: $e'),
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
