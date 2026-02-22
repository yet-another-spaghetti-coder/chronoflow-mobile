import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PermissionDeniedView extends StatelessWidget {
  final VoidCallback onActionPressed;
  final bool isPermanentlyDenied;

  const PermissionDeniedView({
    required this.onActionPressed,
    required this.isPermanentlyDenied,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isCupertino = _isCupertinoPlatform(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isPermanentlyDenied ? 'Camera Permission Denied' : 'Camera Access Required',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isPermanentlyDenied
                  ? 'Camera permission was denied. Please enable it in app settings to use QR scanning.'
                  : 'Camera access is required to scan QR codes for check-in.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildPrimaryButton(
              context: context,
              isCupertino: isCupertino,
              label: isPermanentlyDenied ? 'Open Settings' : 'Grant Permission',
              onPressed: onActionPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required bool isCupertino,
    required String label,
    required VoidCallback onPressed,
  }) {
    if (isCupertino) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  bool _isCupertinoPlatform(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }
}
