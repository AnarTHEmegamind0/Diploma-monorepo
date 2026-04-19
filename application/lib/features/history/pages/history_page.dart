import 'package:core/core/app_theme.dart';
import 'package:core/core/widgets/neo_card.dart';
import 'package:core/core/widgets/status_badge.dart';
import 'package:core/features/audit/providers/audit_provider.dart';
import 'package:core/features/history/models/audit_history_item.dart';
import 'package:core/features/history/pages/audit_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  AuditFilter _activeFilter = AuditFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AuditProvider>();
      if (provider.history.isEmpty && !provider.historyLoading) {
        provider.loadHistory();
      }
    });
  }

  List<AuditHistoryItem> _filtered(List<AuditHistoryItem> items) {
    if (_activeFilter == AuditFilter.all) return items;

    return items.where((item) {
      switch (_activeFilter) {
        case AuditFilter.sent:
          return item.status == AuditStatus.sent;
        case AuditFilter.returned:
          return item.status == AuditStatus.returned;
        case AuditFilter.draft:
          return item.status == AuditStatus.draft;
        case AuditFilter.all:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final items = provider.history;
    final filteredItems = _filtered(items);
    final stats = provider.historyStats;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadHistory,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'Аудитын түүх',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.darkNavy, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: AuditFilter.values.map((filter) {
                      final isActive = filter == _activeFilter;
                      final count = filter == AuditFilter.all
                          ? ' (${items.length})'
                          : '';
                      return GestureDetector(
                        onTap: () => setState(() => _activeFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          color: isActive ? AppColors.orange : AppColors.white,
                          child: Text(
                            '${filter.label}$count',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.white
                                  : AppColors.darkNavy,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatCard(value: '${stats.todayCount}', label: 'ӨНӨӨДӨР'),
                    const SizedBox(width: 12),
                    _StatCard(
                      value: '${stats.thisMonthCount}',
                      label: 'ЭНЭ САР',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(value: '${stats.sentCount}', label: 'ИЛГЭЭСЭН'),
                  ],
                ),
              ),
              if (provider.error != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    provider.error!,
                    style: GoogleFonts.inter(
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (provider.historyLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: NeoCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.history_toggle_off,
                          size: 42,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Одоогоор аудитын түүх алга байна.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AuditDetailPage(auditId: item.id),
                          ),
                        );
                      },
                      child: _AuditHistoryCard(item: item),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NeoCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.syneMono(
                fontSize: 10,
                color: AppColors.textGrey,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditHistoryCard extends StatelessWidget {
  const _AuditHistoryCard({required this.item});

  final AuditHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dotColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.location,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.timeAgo,
                  style: GoogleFonts.syneMono(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildBadge(),
                    Text(
                      '${item.answerCount} хариулт',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      '${item.detectionCount} detection',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _dotColor {
    switch (item.status) {
      case AuditStatus.sent:
        return AppColors.teal;
      case AuditStatus.returned:
        return AppColors.red;
      case AuditStatus.draft:
        return AppColors.orange;
    }
  }

  Widget _buildBadge() {
    switch (item.status) {
      case AuditStatus.sent:
        return StatusBadge.sent();
      case AuditStatus.returned:
        return StatusBadge.returned();
      case AuditStatus.draft:
        return StatusBadge.draft();
    }
  }
}
