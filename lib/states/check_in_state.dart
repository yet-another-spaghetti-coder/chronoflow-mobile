import 'package:permission_handler/permission_handler.dart';

class CheckInState {
  final PermissionStatus cameraPermission;
  final bool isScanning;
  final bool isProcessing;
  final String? lastScannedCode;

  const CheckInState({
    this.cameraPermission = PermissionStatus.denied,
    this.isScanning = true,
    this.isProcessing = false,
    this.lastScannedCode,
  });

  CheckInState copyWith({
    PermissionStatus? cameraPermission,
    bool? isScanning,
    bool? isProcessing,
    String? lastScannedCode,
  }) {
    return CheckInState(
      cameraPermission: cameraPermission ?? this.cameraPermission,
      isScanning: isScanning ?? this.isScanning,
      isProcessing: isProcessing ?? this.isProcessing,
      lastScannedCode: lastScannedCode ?? this.lastScannedCode,
    );
  }
}
