import 'package:chronoflow/widgets/permission_denied_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PermissionDeniedView Widget Tests', () {
    testWidgets('should display camera icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedView(
              isPermanentlyDenied: false,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('should display "Camera Access Required" title when not permanently denied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedView(
              isPermanentlyDenied: false,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Camera Access Required'), findsOneWidget);
    });

    testWidgets('should display "Camera Permission Denied" title when permanently denied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedView(
              isPermanentlyDenied: true,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Camera Permission Denied'), findsOneWidget);
    });

    testWidgets('should display appropriate message when not permanently denied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedView(
              isPermanentlyDenied: false,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Camera access is required to scan QR codes for check-in.'), findsOneWidget);
    });

    testWidgets('should display appropriate message when permanently denied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedView(
              isPermanentlyDenied: true,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('Camera permission was denied. Please enable it in app settings to use QR scanning.'),
        findsOneWidget,
      );
    });

    testWidgets('should display "Grant Permission" button when not permanently denied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedView(
              isPermanentlyDenied: false,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Grant Permission'), findsOneWidget);
    });

    testWidgets('should display "Open Settings" button when permanently denied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedView(
              isPermanentlyDenied: true,
              onActionPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Open Settings'), findsOneWidget);
    });

    testWidgets('should call onActionPressed when button is tapped', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedView(
              isPermanentlyDenied: false,
              onActionPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Grant Permission'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });
  });
}
