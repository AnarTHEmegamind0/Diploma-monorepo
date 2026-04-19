import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core/app_theme.dart';
import 'package:core/core/widgets/neo_card.dart';
import 'package:core/core/widgets/status_badge.dart';
import 'package:core/features/audit/services/audit_service.dart';
import 'package:core/features/history/models/audit_detail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuditDetailPage extends StatefulWidget {
  const AuditDetailPage({super.key, required this.auditId});

  final String auditId;

  @override
  State<AuditDetailPage> createState() => _AuditDetailPageState();
}

class _AuditDetailPageState extends State<AuditDetailPage> {
  AuditDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = context.read<AuditService>();
      final detail = await service.fetchAuditDetail(widget.auditId);
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Аудитын дэлгэрэнгүй',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.darkNavy,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.red),
              const SizedBox(height: 16),
              Text(
                'Алдаа гарлаа',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDetail,
                child: const Text('Дахин оролдох'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;
    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeaderCard(detail),
          const SizedBox(height: 16),
          if (detail.photoUrls.isNotEmpty) ...[
            _buildPhotosSection(detail),
            const SizedBox(height: 16),
          ],
          if (detail.detectionTotal > 0) ...[
            _buildDetectionSection(detail),
            const SizedBox(height: 16),
          ],
          if (detail.answers.isNotEmpty) ...[
            _buildAnswersSection(detail),
            const SizedBox(height: 16),
          ],
          if (detail.notes != null && detail.notes!.isNotEmpty) ...[
            _buildNotesSection(detail),
            const SizedBox(height: 16),
          ],
          if (detail.location != null) ...[
            _buildLocationSection(detail),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(AuditDetail detail) {
    return NeoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.campaignName ?? 'Кампанит ажил',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
              _buildResultBadge(detail.auditResult),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.store, detail.tradeshopName ?? '-'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person, detail.auditorName ?? '-'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, detail.formattedDate),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.tag, 'ID: ${detail.id.substring(0, 8)}...'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.darkNavy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultBadge(String? result) {
    Color bgColor;
    Color textColor;
    String label;

    switch (result) {
      case 'pass':
        bgColor = AppColors.teal;
        textColor = AppColors.white;
        label = 'Амжилттай';
        break;
      case 'warning':
        bgColor = AppColors.orange;
        textColor = AppColors.white;
        label = 'Анхааруулга';
        break;
      case 'fail':
        bgColor = AppColors.red;
        textColor = AppColors.white;
        label = 'Амжилтгүй';
        break;
      default:
        bgColor = AppColors.textGrey;
        textColor = AppColors.white;
        label = result ?? '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: AppColors.darkNavy, width: 2),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPhotosSection(AuditDetail detail) {
    return NeoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library, size: 20, color: AppColors.darkNavy),
              const SizedBox(width: 8),
              Text(
                'Зургууд (${detail.photoUrls.length})',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: detail.photoUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showFullImage(context, detail.photoUrls, index),
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.darkNavy, width: 2),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: detail.photoUrls[index],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, size: 48, color: AppColors.textGrey),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, List<String> urls, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          imageUrls: urls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildDetectionSection(AuditDetail detail) {
    return NeoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, size: 20, color: AppColors.darkNavy),
              const SizedBox(width: 8),
              Text(
                'Detection үр дүн',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
              const Spacer(),
              Text(
                '${detail.detectionProcessingTimeMs.toStringAsFixed(0)}ms',
                style: GoogleFonts.syneMono(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Нийт: ${detail.detectionTotal} бүтээгдэхүүн',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkNavy,
            ),
          ),
          if (detail.detectionSummary != null && detail.detectionSummary!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: detail.detectionSummary!.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.darkNavy, width: 1),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkNavy,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswersSection(AuditDetail detail) {
    return NeoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.question_answer, size: 20, color: AppColors.darkNavy),
              const SizedBox(width: 8),
              Text(
                'Хариултууд (${detail.answers.length})',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...detail.answers.map((answer) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        answer.questionText,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (answer.autoAnswered)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                'AI',
                                style: GoogleFonts.syneMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                          Flexible(
                            child: Text(
                              answer.displayAnswer,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNotesSection(AuditDetail detail) {
    return NeoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes, size: 20, color: AppColors.darkNavy),
              const SizedBox(width: 8),
              Text(
                'Тэмдэглэл',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            detail.notes!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.darkNavy,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(AuditDetail detail) {
    final loc = detail.location!;
    return NeoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: AppColors.darkNavy),
              const SizedBox(width: 8),
              Text(
                'Байршил',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Lat: ${loc.lat.toStringAsFixed(6)}, Lng: ${loc.lng.toStringAsFixed(6)}',
            style: GoogleFonts.syneMono(
              fontSize: 13,
              color: AppColors.darkNavy,
            ),
          ),
          if (loc.accuracy != null)
            Text(
              'Нарийвчлал: ${loc.accuracy!.toStringAsFixed(1)}м',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
        ],
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
          style: GoogleFonts.inter(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.contain,
                placeholder: (_, __) => const CircularProgressIndicator(
                  color: Colors.white,
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
