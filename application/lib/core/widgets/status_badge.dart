import 'package:flutter/material.dart';
import 'package:core/core/app_theme.dart';

/// Status badge with coloured background – used for audit statuses.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor = AppColors.white,
  });

  final String label;
  final Color color;
  final Color textColor;

  factory StatusBadge.sent() =>
      const StatusBadge(label: 'Илгээсэн', color: AppColors.teal);

  factory StatusBadge.returned() =>
      const StatusBadge(label: 'Буцаагдсан', color: AppColors.orange);

  factory StatusBadge.draft() =>
      const StatusBadge(label: 'Ноорог', color: AppColors.teal);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
