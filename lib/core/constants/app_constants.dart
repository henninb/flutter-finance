/// Application-wide constants
class AppConstants {
  // API
  static const String contentTypeJson = 'application/json';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';

  // Hive Boxes
  static const String accountsBox = 'accounts';
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String descriptionsBox = 'descriptions';
  static const String authBox = 'auth';

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // Validation - Account
  static const int accountNameMinLength = 3;
  static const int accountNameMaxLength = 40;
  static const String accountNamePattern = r'^[a-z0-9_]+$';

  // Validation - Transaction
  static const int descriptionMinLength = 1;
  static const int descriptionMaxLength = 75;
  static const int categoryMaxLength = 50;
  static const String categoryPattern = r'^[a-z0-9_]+$';
  static const int notesMaxLength = 100;

  // Currency
  static const String currencySymbol = '\$';
  static const int currencyDecimalPlaces = 2;

  // Transaction States
  static const String transactionStateCleared = 'cleared';
  static const String transactionStateOutstanding = 'outstanding';
  static const String transactionStateFuture = 'future';

  // Account Types
  static const String accountTypeCredit = 'credit';
  static const String accountTypeDebit = 'debit';

  // Transaction Types
  static const String transactionTypeExpense = 'expense';
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeTransfer = 'transfer';

  // Reoccurring Types
  static const String reoccurringTypeOnetime = 'onetime';
  static const String reoccurringTypeWeekly = 'weekly';
  static const String reoccurringTypeFortnightly = 'fortnightly';
  static const String reoccurringTypeMonthly = 'monthly';
  static const String reoccurringTypeQuarterly = 'quarterly';
  static const String reoccurringTypeBiAnnually = 'bi_annually';
  static const String reoccurringTypeAnnually = 'annually';
}
