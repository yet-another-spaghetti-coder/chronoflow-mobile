import 'package:chronoflow/states/check_in_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('CheckInState', () {
    test('should have correct default values', () {
      const state = CheckInState();

      expect(state.cameraPermission, equals(PermissionStatus.denied));
      expect(state.isScanning, isTrue);
      expect(state.isProcessing, isFalse);
      expect(state.lastScannedCode, isNull);
    });

    test('should create state with custom values', () {
      const state = CheckInState(
        cameraPermission: PermissionStatus.granted,
        isScanning: false,
        isProcessing: true,
        lastScannedCode: 'test-code-123',
      );

      expect(state.cameraPermission, equals(PermissionStatus.granted));
      expect(state.isScanning, isFalse);
      expect(state.isProcessing, isTrue);
      expect(state.lastScannedCode, equals('test-code-123'));
    });

    group('copyWith', () {
      test('should return same state when no parameters provided', () {
        const original = CheckInState(
          cameraPermission: PermissionStatus.granted,
          isScanning: false,
          isProcessing: true,
          lastScannedCode: 'test-code',
        );

        final copied = original.copyWith();

        expect(copied.cameraPermission, equals(original.cameraPermission));
        expect(copied.isScanning, equals(original.isScanning));
        expect(copied.isProcessing, equals(original.isProcessing));
        expect(copied.lastScannedCode, equals(original.lastScannedCode));
      });

      test('should update cameraPermission only', () {
        const original = CheckInState();

        final copied = original.copyWith(cameraPermission: PermissionStatus.granted);

        expect(copied.cameraPermission, equals(PermissionStatus.granted));
        expect(copied.isScanning, equals(original.isScanning));
        expect(copied.isProcessing, equals(original.isProcessing));
        expect(copied.lastScannedCode, equals(original.lastScannedCode));
      });

      test('should update isScanning only', () {
        const original = CheckInState();

        final copied = original.copyWith(isScanning: false);

        expect(copied.isScanning, isFalse);
        expect(copied.cameraPermission, equals(original.cameraPermission));
        expect(copied.isProcessing, equals(original.isProcessing));
        expect(copied.lastScannedCode, equals(original.lastScannedCode));
      });

      test('should update isProcessing only', () {
        const original = CheckInState();

        final copied = original.copyWith(isProcessing: true);

        expect(copied.isProcessing, isTrue);
        expect(copied.cameraPermission, equals(original.cameraPermission));
        expect(copied.isScanning, equals(original.isScanning));
        expect(copied.lastScannedCode, equals(original.lastScannedCode));
      });

      test('should update lastScannedCode only', () {
        const original = CheckInState();

        final copied = original.copyWith(lastScannedCode: 'new-code');

        expect(copied.lastScannedCode, equals('new-code'));
        expect(copied.cameraPermission, equals(original.cameraPermission));
        expect(copied.isScanning, equals(original.isScanning));
        expect(copied.isProcessing, equals(original.isProcessing));
      });

      test('should update multiple properties at once', () {
        const original = CheckInState();

        final copied = original.copyWith(
          cameraPermission: PermissionStatus.granted,
          isScanning: false,
          isProcessing: true,
          lastScannedCode: 'multi-update-code',
        );

        expect(copied.cameraPermission, equals(PermissionStatus.granted));
        expect(copied.isScanning, isFalse);
        expect(copied.isProcessing, isTrue);
        expect(copied.lastScannedCode, equals('multi-update-code'));
      });
    });
  });
}
