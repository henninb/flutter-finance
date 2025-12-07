import 'package:equatable/equatable.dart';

/// User model
class User extends Equatable {
  final String username;
  final String? email;

  const User({
    required this.username,
    this.email,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      email: json['email'] as String?,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      if (email != null) 'email': email,
    };
  }

  /// Copy with method
  User copyWith({
    String? username,
    String? email,
  }) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [username, email];

  @override
  String toString() => 'User(username: $username, email: $email)';
}
