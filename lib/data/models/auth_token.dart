/// Authentication token model
class AuthToken {
  final String token;
  final DateTime expiresAt;

  const AuthToken({required this.token, required this.expiresAt});

  /// Check if token is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Create AuthToken from JSON
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['token'] as String,
      expiresAt: _parseExpiry(json['expiresAt']),
    );
  }

  static DateTime _parseExpiry(Object? value) {
    if (value == null) return DateTime.now().add(const Duration(hours: 1));
    try {
      return DateTime.parse(value as String);
    } on FormatException {
      return DateTime.now().add(const Duration(hours: 1));
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'token': token, 'expiresAt': expiresAt.toIso8601String()};
  }
}
