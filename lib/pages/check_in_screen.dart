import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:chronoflow/providers/check_in_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  MobileScannerController? _controller;
  bool _isScanning = true;
  String? _lastScannedCode;
  Timer? _debounceTimer;
  bool _isProcessing = false;
  PermissionStatus _cameraPermission = PermissionStatus.denied;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      _cameraPermission = status;
      _isCheckingPermission = false;
    });

    if (status.isGranted) {
      _initializeController();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _cameraPermission = status;
    });

    if (status.isGranted) {
      _initializeController();
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  void _initializeController() {
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    // Debounce: ignore same code within 2 seconds
    if (code == _lastScannedCode) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _lastScannedCode = null;
    });

    _lastScannedCode = code;
    _handleScan(code);
  }

  void _handleScan(String code) {
    setState(() {
      _isScanning = false;
      _isProcessing = true;
    });

    // Actually pause the scanner
    _controller?.stop();

    _showConfirmationDialog(code);
  }

  void _showConfirmationDialog(String code) {
    AdaptiveAlertDialog.show(
      context: context,
      title: 'Confirm Check-In',
      message: 'Check in attendee: $code?',
      actions: [
        AlertAction(
          title: 'CANCEL',
          style: AlertActionStyle.cancel,
          onPressed: _resumeScanning,
        ),
        AlertAction(
          title: 'CONFIRM',
          onPressed: () {
            _performCheckIn(code);
          },
        ),
      ],
    );
  }

  Future<void> _performCheckIn(String attendeeId) async {
    final checkInService = ref.read(checkInServiceProvider);

    final result = await checkInService.checkIn(attendeeId);

    if (mounted) {
      result.fold(
        (error) {
          AdaptiveSnackBar.show(
            context,
            message: 'Check-in failed: $error',
            type: AdaptiveSnackBarType.error,
          );
        },
        (_) {
          AdaptiveSnackBar.show(
            context,
            message: 'Check-in successful!',
            type: AdaptiveSnackBarType.success,
          );
        },
      );
    }

    _resumeScanning();
  }

  void _resumeScanning() {
    _controller?.start();

    setState(() {
      _isScanning = true;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const AdaptiveScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_cameraPermission.isPermanentlyDenied) {
      return AdaptiveScaffold(
        appBar: const AdaptiveAppBar(
          title: 'Check In',
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Camera Permission Denied',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Camera permission was denied. Please enable it in app settings to use QR scanning.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AdaptiveButton(
                  onPressed: _openAppSettings,
                  label: 'Open Settings',
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_cameraPermission.isDenied) {
      return AdaptiveScaffold(
        appBar: const AdaptiveAppBar(
          title: 'Check In',
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Camera Access Required',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Camera access is required to scan QR codes for check-in.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AdaptiveButton(
                  onPressed: _requestCameraPermission,
                  label: 'Grant Permission',
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AdaptiveScaffold(
      appBar: const AdaptiveAppBar(
        title: 'Check In',
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Position QR code within the square',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            const ColoredBox(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
