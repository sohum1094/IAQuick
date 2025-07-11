// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

import 'package:iaqapp/auth_service.dart';
import 'package:iaqapp/auth/sign_in_screen.dart';

void main() {
  testWidgets('SignInScreen shows sign in and sign up buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthService>(
        create: (_) => AuthService(),
        child: const MaterialApp(home: SignInScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign In with Google'), findsOneWidget);
    if (Platform.isIOS) {
      expect(find.text('Sign In with Apple'), findsOneWidget);
    }
  });
}
