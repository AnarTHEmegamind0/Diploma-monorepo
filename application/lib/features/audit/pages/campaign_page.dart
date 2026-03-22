import 'package:core/core/app_theme.dart';
import 'package:core/core/widgets/neo_card.dart';
import 'package:core/features/audit/models/campaign.dart';
import 'package:core/features/audit/providers/audit_provider.dart';
import 'package:core/features/audit/pages/category_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class CampaignPage extends StatelessWidget {
  const CampaignPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final customer = provider.selectedCustomer;
    final campaigns = provider.campaignsForSelectedCustomer();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: AppColors.darkNavy,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Буцах',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Хөтөлбөр сонго',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                customer?.name ?? '',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textGrey,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Campaign list
            Expanded(
              child: provider.campaignsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : campaigns.isEmpty
                  ? _buildEmptyPlaceholder()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: campaigns.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        return _CampaignCard(
                          campaign: campaigns[i],
                          onTap: () {
                            provider.selectCampaign(campaigns[i]);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CategoryPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),

            // Note
            Padding(
              padding: const EdgeInsets.all(20),
              child: NeoCard(
                fillColor: const Color(0xFFFFF8E1),
                borderColor: AppColors.darkNavy,
                padding: const EdgeInsets.all(16),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.darkNavy,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Санамж: ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text:
                            'Хөтөлбөр сонгосны дараа бүх ангилал болон асуултуудыг дуусгах шаардлагатай.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 64,
            color: AppColors.darkNavy.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Сонгосон дэлгүүрт тохирох кампанит ажил олдсонгүй',
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign, required this.onTap});
  final Campaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.folder_outlined,
                        label: '${campaign.categoryCount} ангилал',
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.help_outline,
                        label: '${campaign.questionCount} асуулт',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
