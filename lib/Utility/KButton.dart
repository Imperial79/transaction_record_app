import 'package:flutter/material.dart';
import 'newColors.dart';

class KButton {
  /// The main action button with high contrast (Inverse of theme)
  static Widget primary(
    BuildContext context, {
    required void Function()? onPressed,
    required String label,
    IconData? icon,
    bool fullWidth = true,
    Color? backgroundColor,
    Color? textColor,
    double? verticalPadding,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? context.textColor,
          foregroundColor: textColor ?? context.scaffoldColor,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding ?? 20,
            horizontal: 24,
          ),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          splashFactory: InkSparkle.splashFactory,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 12),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Alias for primary with full width
  static Widget full(
    BuildContext context, {
    void Function()? onPressed,
    String label = "label",
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return primary(
      context,
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fullWidth: true,
    );
  }

  /// Alias for primary without full width
  static Widget regular(
    BuildContext context, {
    void Function()? onPressed,
    String label = "label",
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return primary(
      context,
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fullWidth: false,
      verticalPadding: 14,
    );
  }

  /// An outlined button with zero radius
  static Widget outline(
    BuildContext context, {
    void Function()? onPressed,
    required String label,
    IconData? icon,
    bool fullWidth = true,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.textColor,
          side: BorderSide(color: context.textColor, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 12),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A text-only button with emphasis
  static Widget text(
    BuildContext context, {
    void Function()? onTap,
    required String label,
    double fontSize = 14,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color ?? context.textColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  /// Special variant for themed actions (e.g. Profit/Loss)
  static Widget themed(
    BuildContext context, {
    required void Function()? onPressed,
    required String label,
    required Color color,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return primary(
      context,
      onPressed: onPressed,
      label: label,
      icon: icon,
      backgroundColor: color,
      textColor: Colors.white,
      fullWidth: fullWidth,
      verticalPadding: 16,
    );
  }
}
