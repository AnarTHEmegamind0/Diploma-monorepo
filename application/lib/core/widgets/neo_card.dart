import 'package:flutter/material.dart';
import 'package:core/core/app_theme.dart';

/// A neobrutalist card with a dark shadow offset – the signature style
/// from the Figma designs.
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.shadowOffset = const Offset(4, 4),
    this.borderWidth = 2,
    this.borderColor = AppColors.darkNavy,
    this.fillColor = AppColors.white,
  });

  final Widget child;
  final EdgeInsets padding;
  final Offset shadowOffset;
  final double borderWidth;
  final Color borderColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(color: borderColor, offset: shadowOffset, blurRadius: 0),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
