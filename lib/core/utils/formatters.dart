import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for formatting data
class Formatters {
  /// Format currency amount
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: AppConstants.currencyDecimalPlaces,
    );
    return formatter.format(amount);
  }

  /// Format date
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// Format date for display (e.g., "Dec 6, 2025")
  static String formatDateDisplay(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Parse date string to DateTime
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Convert account name to display format (remove underscores, capitalize)
  static String formatAccountName(String accountName) {
    return accountName
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  /// Format transaction state for display
  static String formatTransactionState(String state) {
    return state.isEmpty ? '' : state[0].toUpperCase() + state.substring(1);
  }
}
