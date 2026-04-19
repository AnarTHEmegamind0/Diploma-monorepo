import 'package:core/core/app_theme.dart';
import 'package:core/core/widgets/neo_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/detection_result.dart';

/// Widget to display detection results.
class DetectionResultWidget extends StatelessWidget {
  const DetectionResultWidget({
    super.key,
    required this.result,
    this.onClose,
  });

  final DetectionResult result;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Илэрсэн бүтээгдэхүүн',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      '${result.processingTimeMs}ms',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkNavy, width: 2),
                ),
                child: Text(
                  '${result.totalProducts}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (onClose != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ],
          ),
          if (result.productCounts.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...result.productCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ProductCountRow(
                  productName: _formatProductName(entry.key),
                  count: entry.value,
                ),
              );
            }),
          ],
          if (!result.isModelLoaded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkNavy),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: AppColors.darkNavy,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.message ?? 'Model not loaded',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatProductName(String className) {
    return className
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}

class _ProductCountRow extends StatelessWidget {
  const _ProductCountRow({
    required this.productName,
    required this.count,
  });

  final String productName;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getProductColor(productName),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            productName,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.darkNavy,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkNavy,
            ),
          ),
        ),
      ],
    );
  }

  Color _getProductColor(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('coca') || nameLower.contains('cola')) {
      return AppColors.red;
    }
    if (nameLower.contains('fanta')) {
      return AppColors.orange;
    }
    if (nameLower.contains('sprite')) {
      return AppColors.green;
    }
    if (nameLower.contains('bonaqua') || nameLower.contains('water')) {
      return AppColors.teal;
    }
    return AppColors.grey;
  }
}

/// Loading indicator for detection.
class DetectionLoadingWidget extends StatelessWidget {
  const DetectionLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Бүтээгдэхүүн таньж байна...',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  'YOLOv8 model ашиглаж байна',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
