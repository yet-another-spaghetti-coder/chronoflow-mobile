// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:chronoflow/core/di/service_locator.dart';
import 'package:chronoflow/features/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts on login page', (tester) async {
    // Build our app and trigger a frame.
    WidgetsFlutterBinding.ensureInitialized();
    await setupServiceLocator();
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    // Verify that the app initially routes to the login page
    expect(find.text('Login'), findsWidgets);
  });
}
