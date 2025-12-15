import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:auth_flutter/services/auth_service.dart';
import '../mocks.dart';

void main() {
  late MockHttpClient mockHttp;
  late MockSecureStorage mockStorage;
  late AuthService authService;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://dummy.com'));
  });

  setUp(() {
    mockHttp = MockHttpClient();
    mockStorage = MockSecureStorage();
    authService = AuthService(client: mockHttp, storage: mockStorage);
  });

  group('AuthService - Login', () {
    test('Login sukses menyimpan token dan data user', () async {
      // Arrange
      final responseBody = {
        "data": {
          "token": "abc123",
          "user": {"name": "Fauzi", "email": "fauzi@mail.com"},
        },
      };

      when(
        () => mockHttp.post(any(), body: any(named: 'body')),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await authService.login(
        email: 'fauzi@mail.com',
        password: 'password',
      );

      // Assert
      expect(result['data']['token'], 'abc123');
      verify(
        () => mockStorage.write(key: 'auth_token', value: 'abc123'),
      ).called(1);
      verify(
        () => mockStorage.write(key: 'user_name', value: 'Fauzi'),
      ).called(1);
      verify(
        () => mockStorage.write(key: 'user_email', value: 'fauzi@mail.com'),
      ).called(1);
    });

    test('Login gagal melempar HttpException', () async {
      when(
        () => mockHttp.post(any(), body: any(named: 'body')),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
        () => authService.login(email: 'wrong@mail.com', password: 'wrong'),
        throwsA(isA<HttpException>()),
      );
    });
  });

  group('AuthService - Logout', () {
    test('Logout menghapus seluruh data auth', () async {
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await authService.logout();

      verify(() => mockStorage.delete(key: 'auth_token')).called(1);
      verify(() => mockStorage.delete(key: 'user_name')).called(1);
      verify(() => mockStorage.delete(key: 'user_email')).called(1);
    });
  });
}
