import 'package:equatable/equatable.dart';

/// Account model
class Account extends Equatable {
  final int? accountId;
  final String accountNameOwner;
  final String accountType;
  final String? moniker;
  final double cleared;
  final double outstanding;
  final double future;
  final bool activeStatus;
  final DateTime? validationDate;

  const Account({
    this.accountId,
    required this.accountNameOwner,
    required this.accountType,
    this.moniker,
    this.cleared = 0.0,
    this.outstanding = 0.0,
    this.future = 0.0,
    this.activeStatus = true,
    this.validationDate,
  });

  /// Get total (computed property)
  double get total => cleared + outstanding + future;

  /// Create Account from JSON
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'] as int?,
      accountNameOwner: json['accountNameOwner'] as String,
      accountType: json['accountType'] as String,
      moniker: json['moniker'] as String?,
      cleared: (json['cleared'] as num?)?.toDouble() ?? 0.0,
      outstanding: (json['outstanding'] as num?)?.toDouble() ?? 0.0,
      future: (json['future'] as num?)?.toDouble() ?? 0.0,
      activeStatus: json['activeStatus'] as bool? ?? true,
      validationDate: json['validationDate'] != null
          ? DateTime.parse(json['validationDate'] as String)
          : null,
    );
  }

  /// Convert Account to JSON
  Map<String, dynamic> toJson() {
    return {
      if (accountId != null) 'accountId': accountId,
      'accountNameOwner': accountNameOwner,
      'accountType': accountType,
      if (moniker != null) 'moniker': moniker,
      'cleared': cleared,
      'outstanding': outstanding,
      'future': future,
      'activeStatus': activeStatus,
      if (validationDate != null)
        'validationDate': validationDate!.toIso8601String(),
    };
  }

  /// Copy with method
  Account copyWith({
    int? accountId,
    String? accountNameOwner,
    String? accountType,
    String? moniker,
    double? cleared,
    double? outstanding,
    double? future,
    bool? activeStatus,
    DateTime? validationDate,
  }) {
    return Account(
      accountId: accountId ?? this.accountId,
      accountNameOwner: accountNameOwner ?? this.accountNameOwner,
      accountType: accountType ?? this.accountType,
      moniker: moniker ?? this.moniker,
      cleared: cleared ?? this.cleared,
      outstanding: outstanding ?? this.outstanding,
      future: future ?? this.future,
      activeStatus: activeStatus ?? this.activeStatus,
      validationDate: validationDate ?? this.validationDate,
    );
  }

  @override
  List<Object?> get props => [
        accountId,
        accountNameOwner,
        accountType,
        moniker,
        cleared,
        outstanding,
        future,
        activeStatus,
        validationDate,
      ];

  @override
  String toString() {
    return 'Account(accountId: $accountId, accountNameOwner: $accountNameOwner, accountType: $accountType, total: $total)';
  }
}
