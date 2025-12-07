import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/account_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../providers/transaction_provider.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  final Account account;

  const AddTransactionDialog({
    super.key,
    required this.account,
  });

  @override
  ConsumerState<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _transactionState = 'outstanding';
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
      // Generate UUID
      final repository = ref.read(transactionRepositoryProvider);
      final uuid = await repository.generateUuid();

      // Create transaction
      final transaction = Transaction(
        guid: uuid,
        accountNameOwner: widget.account.accountNameOwner,
        accountType: widget.account.accountType,
        transactionDate: _selectedDate,
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim().toLowerCase(),
        amount: double.parse(_amountController.text),
        transactionState: _transactionState,
        notes: _notesController.text.trim(),
      );

      // Add transaction
      await ref
          .read(transactionsProvider(widget.account.accountNameOwner).notifier)
          .addTransaction(transaction);

      // Invalidate totals to refresh them
      ref.invalidate(transactionTotalsProvider(widget.account.accountNameOwner));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add transaction: $e'),
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
                        Icons.add_circle_outline,
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
                            'Add Transaction',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            widget.account.accountNameOwner,
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

                // Submit button
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
                      : const Text('Add Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
