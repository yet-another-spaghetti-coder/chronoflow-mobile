import 'dart:async';

import 'package:chronoflow/services/check_in_service.dart';
import 'package:chronoflow/states/check_in_state.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckInNotifier extends StateNotifier<CheckInState> {
  final CheckInService _checkInService;
  Timer? _debounceTimer;

  CheckInNotifier(this._checkInService) : super(const CheckInState());

  Future<void> checkCameraPermission() async {
    final status = await Permission.camera.status;
    state = state.copyWith(cameraPermission: status);
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    state = state.copyWith(cameraPermission: status);
  }

  void onBarcodeDetected(String code) {
    // Don't process if not scanning or already processing
    if (!state.isScanning || state.isProcessing) return;

    // Don't process same code again (debounce)
    if (code == state.lastScannedCode) return;

    // Cancel any existing debounce timer
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      // Reset last scanned code after debounce period by creating new state
      state = CheckInState(
        cameraPermission: state.cameraPermission,
        isScanning: state.isScanning,
        isProcessing: state.isProcessing,
      );
    });

    state = state.copyWith(
      lastScannedCode: code,
      isScanning: false,
      isProcessing: true,
    );
  }

  Future<void> performCheckIn(String attendeeId) async {
    await _checkInService.checkIn(attendeeId);
    // Resume scanning after check-in attempt (success or failure)
    resumeScanning();
  }

  void resumeScanning() {
    state = state.copyWith(
      isScanning: true,
      isProcessing: false,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
