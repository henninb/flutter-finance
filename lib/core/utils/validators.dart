import '../constants/app_constants.dart';

/// Utility class for data validation
class Validators {
  /// Validate account name
  static String? validateAccountName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account name is required';
    }
    if (value.length < AppConstants.accountNameMinLength) {
      return 'Account name must be at least ${AppConstants.accountNameMinLength} characters';
    }
    if (value.length > AppConstants.accountNameMaxLength) {
      return 'Account name must be at most ${AppConstants.accountNameMaxLength} characters';
    }
    if (!RegExp(AppConstants.accountNamePattern).hasMatch(value)) {
      return 'Account name must be lowercase letters, numbers, and underscores only';
    }
    return null;
  }

  /// Validate description
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    if (value.length < AppConstants.descriptionMinLength) {
      return 'Description must be at least ${AppConstants.descriptionMinLength} character';
    }
    if (value.length > AppConstants.descriptionMaxLength) {
      return 'Description must be at most ${AppConstants.descriptionMaxLength} characters';
    }
    return null;
  }

  /// Validate category
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category is required';
    }
    if (value.length > AppConstants.categoryMaxLength) {
      return 'Category must be at most ${AppConstants.categoryMaxLength} characters';
    }
    if (!RegExp(AppConstants.categoryPattern).hasMatch(value)) {
      return 'Category must be lowercase letters, numbers, and underscores only';
    }
    return null;
  }

  /// Validate amount
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Amount must be a valid number';
    }
    return null;
  }

  /// Validate notes
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Notes are optional
    }
    if (value.length > AppConstants.notesMaxLength) {
      return 'Notes must be at most ${AppConstants.notesMaxLength} characters';
    }
    return null;
  }

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validate moniker (4 digits)
  static String? validateMoniker(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Moniker is optional
    }
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'Moniker must be exactly 4 digits';
    }
    return null;
  }
}
