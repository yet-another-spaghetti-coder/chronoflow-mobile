import 'package:chronoflow/widgets/qr_scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QRScannerOverlay Widget Tests', () {
    testWidgets('should render a centered container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                QRScannerOverlay(),
              ],
            ),
          ),
        ),
      );

      // The overlay should be a Center widget
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should have a container with specific dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                QRScannerOverlay(),
              ],
            ),
          ),
        ),
      );

      // Find the container with the expected dimensions
      final container = tester.widget<Container>(find.byType(Container).first);
      final constraints = container.constraints;

      // The overlay should have width and height constraints of 250
      expect(constraints?.maxWidth, equals(250));
      expect(constraints?.maxHeight, equals(250));
    });

    testWidgets('should have a border with white color and width 2', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                QRScannerOverlay(),
              ],
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration, isNotNull);
      expect(decoration!.border, isNotNull);

      final border = decoration.border as Border?;
      expect(border, isNotNull);

      // Check that all sides have the same border
      expect(border!.top.width, equals(2));
      expect(border.top.color, equals(Colors.white));
    });

    testWidgets('should have a border radius of 12', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                QRScannerOverlay(),
              ],
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration, isNotNull);
      expect(decoration!.borderRadius, equals(BorderRadius.circular(12)));
    });

    testWidgets('should render correctly within a Stack', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                QRScannerOverlay(),
              ],
            ),
          ),
        ),
      );

      // Should find QRScannerOverlay widget
      expect(find.byType(QRScannerOverlay), findsOneWidget);
    });
  });
}
