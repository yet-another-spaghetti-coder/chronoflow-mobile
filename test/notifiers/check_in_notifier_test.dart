import 'package:chronoflow/notifiers/check_in_notifier.dart';
import 'package:chronoflow/services/check_in_service.dart';
import 'package:chronoflow/states/check_in_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'check_in_notifier_test.mocks.dart';

@GenerateMocks([CheckInService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCheckInService mockCheckInService;
  late CheckInNotifier notifier;

  setUp(() {
    mockCheckInService = MockCheckInService();
    // Provide a default stub that returns a valid Either to avoid MissingDummyValueError
    // Using provideDummy to give a fallback value for any unmatched calls
    provideDummy<Either<String, String>>(const Right<String, String>('dummy'));
    // Setup stub that returns a valid Either
    when(mockCheckInService.checkIn(any)).thenAnswer(
      (_) async => const Right<String, String>('Check-in successful'),
    );
    notifier = CheckInNotifier(mockCheckInService);
  });

  group('CheckInNotifier', () {
    test('should have correct initial state', () {
      expect(notifier.state.cameraPermission, equals(const CheckInState().cameraPermission));
      expect(notifier.state.isScanning, isTrue);
      expect(notifier.state.isProcessing, isFalse);
      expect(notifier.state.lastScannedCode, isNull);
    });

    group('onBarcodeDetected', () {
      test('should update state when barcode is detected while scanning', () {
        const testCode = 'http://example.com?token=test-token';

        notifier.onBarcodeDetected(testCode);

        expect(notifier.state.lastScannedCode, equals(testCode));
        expect(notifier.state.isScanning, isFalse);
        expect(notifier.state.isProcessing, isTrue);
      });

      test('should not update state when already processing', () {
        const testCode = 'http://example.com?token=test-token';

        notifier.onBarcodeDetected(testCode);
        final firstCode = notifier.state.lastScannedCode;

        // Try to detect another code while processing
        notifier.onBarcodeDetected('http://example.com?token=another-token');

        // State should remain the same since isProcessing is true
        expect(notifier.state.lastScannedCode, equals(firstCode));
      });

      test('should accept new code after scanning is resumed', () {
        const firstCode = 'http://example.com?token=first-token';
        const secondCode = 'http://example.com?token=second-token';

        notifier
          ..onBarcodeDetected(firstCode)
          ..resumeScanning()
          ..onBarcodeDetected(secondCode);

        // After resuming, should accept new code
        expect(notifier.state.lastScannedCode, equals(secondCode));
      });

      test('should not update state for duplicate barcode', () {
        const testCode = 'http://example.com?token=test-token';

        notifier
          ..onBarcodeDetected(testCode)
          // Try to scan same code again
          ..onBarcodeDetected(testCode);

        // Should not change state (debounce behavior)
        expect(notifier.state.lastScannedCode, equals(testCode));
      });
    });

    group('performCheckIn', () {
      test('should call checkIn service and resume scanning on success', () async {
        const testCode = 'http://example.com?token=test-token';

        await notifier.performCheckIn(testCode);

        verify(mockCheckInService.checkIn(testCode)).called(1);
        // State should resume scanning after successful check-in
        expect(notifier.state.isScanning, isTrue);
        expect(notifier.state.isProcessing, isFalse);
      });

      test('should resume scanning on check-in failure', () async {
        const testCode = 'http://example.com?token=test-token';
        when(mockCheckInService.checkIn(testCode)).thenAnswer(
          (_) async => const Left<String, String>('Check-in failed'),
        );

        await notifier.performCheckIn(testCode);

        verify(mockCheckInService.checkIn(testCode)).called(1);
        // State should resume scanning after failed check-in too
        expect(notifier.state.isScanning, isTrue);
        expect(notifier.state.isProcessing, isFalse);
      });
    });

    group('resumeScanning', () {
      test('should resume scanning and reset processing state', () {
        const testCode = 'http://example.com?token=test-token';

        notifier.onBarcodeDetected(testCode);
        expect(notifier.state.isScanning, isFalse);
        expect(notifier.state.isProcessing, isTrue);

        notifier.resumeScanning();

        expect(notifier.state.isScanning, isTrue);
        expect(notifier.state.isProcessing, isFalse);
      });
    });
  });
}
