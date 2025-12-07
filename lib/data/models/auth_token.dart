/// Authentication token model
class AuthToken {
  final String token;
  final DateTime expiresAt;

  const AuthToken({
    required this.token,
    required this.expiresAt,
  });

  /// Check if token is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Create AuthToken from JSON
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['token'] as String,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(hours: 1)),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}
