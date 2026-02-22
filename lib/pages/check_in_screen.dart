import 'dart:async';

import 'package:chronoflow/providers/check_in_provider.dart';
import 'package:chronoflow/widgets/permission_denied_view.dart';
import 'package:chronoflow/widgets/qr_scanner_overlay.dart';
import 'package:flutter/cupertino.dart';
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
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final notifier = ref.read(checkInNotifierProvider.notifier);
    await notifier.checkCameraPermission();

    if (!mounted) return;

    final state = ref.read(checkInNotifierProvider);
    setState(() {
      _isCheckingPermission = false;
    });

    if (state.cameraPermission.isGranted) {
      _initializeController();
    }
  }

  Future<void> _requestCameraPermission() async {
    final notifier = ref.read(checkInNotifierProvider.notifier);
    await notifier.requestCameraPermission();

    if (!mounted) return;

    final state = ref.read(checkInNotifierProvider);
    if (state.cameraPermission.isGranted) {
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
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final notifier = ref.read(checkInNotifierProvider.notifier);

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    notifier.onBarcodeDetected(code);

    final state = ref.read(checkInNotifierProvider);
    if (state.isProcessing && state.lastScannedCode != null) {
      _controller?.stop();
      _showConfirmationDialog(code);
    }
  }

  void _showConfirmationDialog(String code) {
    if (_isCupertinoPlatform) {
      showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Confirm Check-In'),
          content: Text('Check in attendee: $code?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(ctx).pop();
                _resumeScanning();
              },
              child: const Text('CANCEL'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(ctx).pop();
                _performCheckIn(code);
              },
              child: const Text('CONFIRM'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Check-In'),
        content: Text('Check in attendee: $code?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resumeScanning();
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _performCheckIn(code);
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCheckIn(String attendeeId) async {
    final notifier = ref.read(checkInNotifierProvider.notifier);
    await notifier.performCheckIn(attendeeId);

    if (!mounted) return;

    _showResultMessage(message: 'Check-in processed', isSuccess: true);

    _resumeScanning();
  }

  void _resumeScanning() {
    _controller?.start();
    final _ = ref.read(checkInNotifierProvider.notifier)..resumeScanning();
  }

  bool get _isCupertinoPlatform {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  void _showResultMessage({required String message, required bool isSuccess}) {
    if (_isCupertinoPlatform) {
      showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildScreenScaffold({required Widget body}) {
    if (_isCupertinoPlatform) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Check In'),
        ),
        child: SafeArea(child: body),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: body,
    );
  }

  Widget _buildProgressIndicator() {
    if (_isCupertinoPlatform) {
      return const CupertinoActivityIndicator();
    }

    return const CircularProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkInNotifierProvider);

    if (_isCheckingPermission) {
      return _buildScreenScaffold(
        body: Center(child: _buildProgressIndicator()),
      );
    }

    if (state.cameraPermission.isPermanentlyDenied) {
      return _buildScreenScaffold(
        body: PermissionDeniedView(
          isPermanentlyDenied: true,
          onActionPressed: _openAppSettings,
        ),
      );
    }

    if (state.cameraPermission.isDenied) {
      return _buildScreenScaffold(
        body: PermissionDeniedView(
          isPermanentlyDenied: false,
          onActionPressed: _requestCameraPermission,
        ),
      );
    }

    return _buildScreenScaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          const QRScannerOverlay(),
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
          if (state.isProcessing)
            const ColoredBox(
              color: Colors.black54,
              child: Center(
                child: _ProcessingIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProcessingIndicator extends StatelessWidget {
  const _ProcessingIndicator();

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isCupertino) {
      return const CupertinoActivityIndicator();
    }

    return const CircularProgressIndicator(color: Colors.white);
  }
}
