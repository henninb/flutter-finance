import 'package:equatable/equatable.dart';

/// CSRF token model for Cross-Site Request Forgery protection
class CsrfToken extends Equatable {
  final String token;
  final String headerName;
  final String parameterName;

  const CsrfToken({
    required this.token,
    required this.headerName,
    required this.parameterName,
  });

  /// Create CsrfToken from JSON
  factory CsrfToken.fromJson(Map<String, dynamic> json) {
    return CsrfToken(
      token: json['token'] as String,
      headerName: json['headerName'] as String? ?? 'X-CSRF-TOKEN',
      parameterName: json['parameterName'] as String? ?? '_csrf',
    );
  }

  /// Convert CsrfToken to JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'headerName': headerName,
      'parameterName': parameterName,
    };
  }

  @override
  List<Object?> get props => [token, headerName, parameterName];
}
