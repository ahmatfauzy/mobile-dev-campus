import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:auth_flutter/pages/login_page.dart';
import 'package:auth_flutter/services/auth_service.dart';
import '../mocks/mock_auth_service.dart';

void main() {
  late MockAuthService mockAuth;

  setUp(() {
    mockAuth = MockAuthService();
  });

  testWidgets('Login sukses → navigasi ke ProfilePage', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(
      () => mockAuth.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => {});

    await tester.pumpWidget(
      MaterialApp(
        routes: {'/profile': (_) => const Scaffold(body: Text('Profile Page'))},
        home: LoginPage(authService: mockAuth),
      ),
    );

    // Act
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'test@mail.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'password');

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Profile Page'), findsOneWidget);
  });

  testWidgets('Login gagal → menampilkan SnackBar error', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(
      () => mockAuth.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(HttpException('Login gagal', statusCode: 401));

    await tester.pumpWidget(
      MaterialApp(home: LoginPage(authService: mockAuth)),
    );

    // Act
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'wrong@mail.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump(); // tampilkan SnackBar

    // Assert
    expect(find.text('Login gagal'), findsOneWidget);
  });
}
