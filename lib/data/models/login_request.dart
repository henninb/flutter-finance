/// Login request model
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
