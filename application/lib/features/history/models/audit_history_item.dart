import 'package:intl/intl.dart';

/// Status of an audit history entry.
enum AuditStatus {
  sent,
  returned,
  draft;

  String get label {
    switch (this) {
      case AuditStatus.sent:
        return 'Илгээсэн';
      case AuditStatus.returned:
        return 'Буцаагдсан';
      case AuditStatus.draft:
        return 'Ноорог';
    }
  }
}

/// Filter tab options for the history page.
enum AuditFilter {
  all,
  sent,
  returned,
  draft;

  String get label {
    switch (this) {
      case AuditFilter.all:
        return 'Бүгд';
      case AuditFilter.sent:
        return 'Илгээсэн';
      case AuditFilter.returned:
        return 'Буцаагдсан';
      case AuditFilter.draft:
        return 'Ноорог';
    }
  }
}

/// A single audit history entry.
class AuditHistoryItem {
  const AuditHistoryItem({
    required this.id,
    required this.title,
    required this.location,
    required this.submittedAt,
    required this.status,
    this.answerCount = 0,
    this.detectionCount = 0,
  });

  final String id;
  final String title;
  final String location;
  final DateTime submittedAt;
  final AuditStatus status;
  final int answerCount;
  final int detectionCount;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(submittedAt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} минутын өмнө';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} цагийн өмнө';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} өдрийн өмнө';
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(submittedAt);
  }

  factory AuditHistoryItem.fromJson(Map<String, dynamic> json) {
    return AuditHistoryItem(
      id: json['id']?.toString() ?? '',
      title: json['campaign_name']?.toString() ?? 'Кампанит ажил',
      location: json['tradeshop_name']?.toString() ?? 'Дэлгүүр',
      submittedAt:
          DateTime.tryParse(json['submitted_at']?.toString() ?? '') ??
          DateTime.now(),
      status: AuditStatus.sent,
      answerCount: (json['answers'] as List<dynamic>?)?.length ?? 0,
      detectionCount: (json['detection_total'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Summary statistics shown in the stat cards.
class AuditHistoryStats {
  const AuditHistoryStats({
    required this.todayCount,
    required this.thisMonthCount,
    required this.sentCount,
  });

  final int todayCount;
  final int thisMonthCount;
  final int sentCount;

  factory AuditHistoryStats.fromItems(List<AuditHistoryItem> items) {
    final now = DateTime.now();
    final today = items.where((item) {
      final submitted = item.submittedAt;
      return submitted.year == now.year &&
          submitted.month == now.month &&
          submitted.day == now.day;
    }).length;

    final thisMonth = items.where((item) {
      final submitted = item.submittedAt;
      return submitted.year == now.year && submitted.month == now.month;
    }).length;

    final sent = items.where((item) => item.status == AuditStatus.sent).length;

    return AuditHistoryStats(
      todayCount: today,
      thisMonthCount: thisMonth,
      sentCount: sent,
    );
  }
}
