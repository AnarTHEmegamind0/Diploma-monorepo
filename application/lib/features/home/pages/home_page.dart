import 'package:core/core/app_theme.dart';
import 'package:core/core/widgets/neo_button.dart';
import 'package:core/core/widgets/neo_card.dart';
import 'package:core/features/audit/providers/audit_provider.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/shell/service/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AuditProvider>();
      await provider.ensureCurrentLocation(requestPermission: true);
      await provider.loadCampaigns();
      await provider.loadCustomers();
      await provider.loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthProvider provider) => provider.user);
    final auditProvider = context.watch<AuditProvider>();
    final campaigns = auditProvider.campaigns;
    final todayTaskCount = auditProvider.todayTaskCount;
    final totalTaskCount = auditProvider.totalTaskCount;
    final completed = auditProvider.completedTaskCount;
    final progress = totalTaskCount == 0 ? 0.0 : completed / totalTaskCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await auditProvider.ensureCurrentLocation(requestPermission: true);
            await auditProvider.loadCampaigns();
            await auditProvider.loadCustomers();
            await auditProvider.loadHistory();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              Text(
                'Сайн уу, ${user?.name ?? 'Аудитор'}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.groupName ?? 'Өнөөдрийн ажлуудаа шалгаарай',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 24),
              NeoCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'ӨНӨӨДРИЙН ДААЛГАВАР',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkNavy,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            '${campaigns.length} кампанит ажил',
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$completed/$totalTaskCount',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkNavy,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Дууссан аудит',
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.lightGrey,
                        color: AppColors.orange,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.lightGrey, height: 1),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatChip(
                          icon: Icons.storefront_outlined,
                          label: 'Үлдсэн',
                          value: '$todayTaskCount',
                        ),
                        _StatChip(
                          icon: Icons.history,
                          label: 'Энэ сар',
                          value: '${auditProvider.historyStats.thisMonthCount}',
                        ),
                        _StatChip(
                          icon: Icons.check_circle_outline,
                          label: 'Өнөөдөр',
                          value: '${auditProvider.historyStats.todayCount}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (auditProvider.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  auditProvider.error!,
                  style: const TextStyle(color: AppColors.red),
                ),
              ],
              if (auditProvider.locationMessage != null) ...[
                const SizedBox(height: 16),
                NeoCard(
                  padding: const EdgeInsets.all(16),
                  fillColor: const Color(0xFFFFF8E1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Байршлын шалгалт',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        auditProvider.locationMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.darkNavy,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      NeoButton(
                        label: auditProvider.locationLoading
                            ? 'Шалгаж байна...'
                            : 'Байршил дахин шалгах',
                        backgroundColor: AppColors.orange,
                        onPressed: auditProvider.locationLoading
                            ? null
                            : () async {
                                await auditProvider.ensureCurrentLocation(
                                  requestPermission: true,
                                );
                                await auditProvider.loadCustomers();
                              },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'Миний дэлгүүрүүд',
                      subtitle: '$totalTaskCount цэг',
                      onTap: () {
                        context.read<NavigationController>().setIndex(1);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.history,
                      title: 'Аудитын түүх',
                      subtitle: '${auditProvider.history.length} илгээсэн',
                      onTap: () {
                        context.read<NavigationController>().setIndex(2);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              NeoCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Идэвхтэй кампанит ажлууд',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (auditProvider.campaignsLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (campaigns.isEmpty)
                      Text(
                        'Идэвхтэй кампанит ажил алга байна.',
                        style: GoogleFonts.inter(color: AppColors.textGrey),
                      )
                    else
                      ...campaigns
                          .take(3)
                          .map(
                            (campaign) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          campaign.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkNavy,
                                          ),
                                        ),
                                        Text(
                                          '${campaign.completedTradeshops}/${campaign.totalTradeshops} цэг',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${campaign.progressPercent.toStringAsFixed(0)}%',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              NeoButton(
                label: 'Аудит эхлүүлэх',
                backgroundColor: AppColors.orange,
                onPressed: () {
                  context.read<NavigationController>().setIndex(1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.darkNavy, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.orange),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.orange, size: 22),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
