import 'package:flutter/material.dart';
import 'newColors.dart';

class KLoading extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const KLoading({
    super.key,
    this.size = 24,
    this.strokeWidth = 2,
    this.color,
  });

  /// Full page loading overlay style with optional label
  static Widget fullPage(BuildContext context, {String label = "PROCESSING..."}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const KLoading(),
          const SizedBox(height: 24),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: context.fadeTextColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? context.textColor.lighten(0.2),
        ),
      ),
    );
  }
}
