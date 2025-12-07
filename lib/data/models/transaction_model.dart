import 'package:equatable/equatable.dart';

/// Transaction model
class Transaction extends Equatable {
  final int? transactionId;
  final String guid;
  final int? accountId;
  final String accountNameOwner;
  final String accountType;
  final DateTime transactionDate;
  final String description;
  final String category;
  final double amount;
  final String transactionState;
  final String transactionType;
  final String reoccurringType;
  final bool activeStatus;
  final String notes;

  const Transaction({
    this.transactionId,
    required this.guid,
    this.accountId,
    required this.accountNameOwner,
    required this.accountType,
    required this.transactionDate,
    required this.description,
    required this.category,
    required this.amount,
    required this.transactionState,
    this.transactionType = 'expense',
    this.reoccurringType = 'onetime',
    this.activeStatus = true,
    this.notes = '',
  });

  /// Create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'] as int?,
      guid: json['guid'] as String,
      accountId: json['accountId'] as int?,
      accountNameOwner: json['accountNameOwner'] as String,
      accountType: json['accountType'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      description: json['description'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionState: json['transactionState'] as String,
      transactionType: json['transactionType'] as String? ?? 'expense',
      reoccurringType: json['reoccurringType'] as String? ?? 'onetime',
      activeStatus: json['activeStatus'] as bool? ?? true,
      notes: json['notes'] as String? ?? '',
    );
  }

  /// Convert Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      if (transactionId != null) 'transactionId': transactionId,
      'guid': guid,
      if (accountId != null) 'accountId': accountId,
      'accountNameOwner': accountNameOwner,
      'accountType': accountType,
      'transactionDate': transactionDate.toIso8601String().split('T')[0], // yyyy-MM-dd format
      'description': description,
      'category': category,
      'amount': amount,
      'transactionState': transactionState,
      'transactionType': transactionType,
      'reoccurringType': reoccurringType,
      'activeStatus': activeStatus,
      'notes': notes,
    };
  }

  /// Copy with method
  Transaction copyWith({
    int? transactionId,
    String? guid,
    int? accountId,
    String? accountNameOwner,
    String? accountType,
    DateTime? transactionDate,
    String? description,
    String? category,
    double? amount,
    String? transactionState,
    String? transactionType,
    String? reoccurringType,
    bool? activeStatus,
    String? notes,
  }) {
    return Transaction(
      transactionId: transactionId ?? this.transactionId,
      guid: guid ?? this.guid,
      accountId: accountId ?? this.accountId,
      accountNameOwner: accountNameOwner ?? this.accountNameOwner,
      accountType: accountType ?? this.accountType,
      transactionDate: transactionDate ?? this.transactionDate,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      transactionState: transactionState ?? this.transactionState,
      transactionType: transactionType ?? this.transactionType,
      reoccurringType: reoccurringType ?? this.reoccurringType,
      activeStatus: activeStatus ?? this.activeStatus,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        guid,
        accountId,
        accountNameOwner,
        accountType,
        transactionDate,
        description,
        category,
        amount,
        transactionState,
        transactionType,
        reoccurringType,
        activeStatus,
        notes,
      ];

  @override
  String toString() {
    return 'Transaction(guid: $guid, description: $description, amount: $amount, state: $transactionState)';
  }
}
