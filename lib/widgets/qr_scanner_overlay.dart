import 'package:flutter/material.dart';

class QRScannerOverlay extends StatelessWidget {
  final double width;
  final double height;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  const QRScannerOverlay({
    super.key,
    this.width = 250,
    this.height = 250,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
