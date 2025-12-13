import 'package:dio/dio.dart';
import 'package:flutter_finance/data/models/auth_token.dart';
import 'package:flutter_finance/data/models/login_request.dart';
import 'package:flutter_finance/data/models/user_model.dart';
import 'package:flutter_finance/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late AuthRepository authRepository;

  setUp(() {
    mockDio = MockDio();
    authRepository = AuthRepository(mockDio);
  });

  group('AuthRepository Tests', () {
    test('login should return AuthToken on success', () async {
      // Arrange
      final request = LoginRequest(username: 'testuser', password: 'password123');
      final responseData = {
        'token': 'test-jwt-token',
      };

      when(
        mockDio.post(
          '/login',
          data: anyNamed('data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/login'),
          statusCode: 200,
          data: responseData,
        ),
      );

      // Act
      final result = await authRepository.login(request);

      // Assert
      expect(result, isA<AuthToken>());
      expect(result.token, 'test-jwt-token');
      verify(
        mockDio.post(
          '/login',
          data: anyNamed('data'),
        ),
      ).called(1);
    });

    test('login should throw exception on failure', () async {
      // Arrange
      final request = LoginRequest(username: 'testuser', password: 'wrongpassword');

      when(
        mockDio.post(
          '/login',
          data: anyNamed('data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/login'),
            statusCode: 401,
            data: {'error': 'Invalid credentials'},
          ),
        ),
      );

      // Act & Assert
      expect(
        () => authRepository.login(request),
        throwsA(isA<Exception>()),
      );
    });

    test('getCurrentUser should return User on success', () async {
      // Arrange
      final responseData = {
        'username': 'testuser',
        'email': 'test@example.com',
      };

      when(mockDio.get('/me')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/me'),
          statusCode: 200,
          data: responseData,
        ),
      );

      // Act
      final result = await authRepository.getCurrentUser();

      // Assert
      expect(result, isA<User>());
      expect(result.username, 'testuser');
      expect(result.email, 'test@example.com');
      verify(mockDio.get('/me')).called(1);
    });

    test('logout should call logout endpoint', () async {
      // Arrange
      when(mockDio.post('/logout')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/logout'),
          statusCode: 200,
        ),
      );

      // Act
      await authRepository.logout();

      // Assert
      verify(mockDio.post('/logout')).called(1);
    });
  });
}
