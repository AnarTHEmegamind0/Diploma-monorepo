import 'package:intl/intl.dart';

/// Detection item from YOLO model.
class DetectionItem {
  const DetectionItem({
    required this.className,
    required this.confidence,
    this.bbox,
  });

  final String className;
  final double confidence;
  final List<double>? bbox;

  factory DetectionItem.fromJson(Map<String, dynamic> json) {
    return DetectionItem(
      className: json['class_name']?.toString() ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      bbox: (json['bbox'] as List<dynamic>?)?.cast<num>().map((e) => e.toDouble()).toList(),
    );
  }
}

/// Answer to a survey question.
class AuditAnswer {
  const AuditAnswer({
    required this.questionId,
    required this.questionText,
    required this.answer,
    this.autoAnswered = false,
  });

  final String questionId;
  final String questionText;
  final dynamic answer;
  final bool autoAnswered;

  factory AuditAnswer.fromJson(Map<String, dynamic> json) {
    return AuditAnswer(
      questionId: json['question_id']?.toString() ?? '',
      questionText: json['question_text']?.toString() ?? '',
      answer: json['answer'],
      autoAnswered: json['auto_answered'] == true,
    );
  }

  String get displayAnswer {
    if (answer == null) return '-';
    if (answer is bool) return answer ? 'Тийм' : 'Үгүй';
    return answer.toString();
  }
}

/// Location where audit was performed.
class AuditDetailLocation {
  const AuditDetailLocation({
    required this.lat,
    required this.lng,
    this.accuracy,
  });

  final double lat;
  final double lng;
  final double? accuracy;

  factory AuditDetailLocation.fromJson(Map<String, dynamic> json) {
    return AuditDetailLocation(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }
}

/// Full audit detail model.
class AuditDetail {
  const AuditDetail({
    required this.id,
    required this.campaignId,
    required this.campaignName,
    required this.tradeshopId,
    required this.tradeshopName,
    required this.auditorId,
    required this.auditorName,
    required this.surveyId,
    required this.answers,
    required this.photos,
    required this.photoUrls,
    required this.status,
    required this.submittedAt,
    required this.createdAt,
    this.detectionId,
    this.detectionSummary,
    this.detectionItems = const [],
    this.detectionTotal = 0,
    this.detectionProcessingTimeMs = 0.0,
    this.location,
    this.notes,
    this.auditResult,
  });

  final String id;
  final String campaignId;
  final String? campaignName;
  final String tradeshopId;
  final String? tradeshopName;
  final String auditorId;
  final String? auditorName;
  final String surveyId;
  final String? detectionId;
  final Map<String, int>? detectionSummary;
  final List<DetectionItem> detectionItems;
  final int detectionTotal;
  final double detectionProcessingTimeMs;
  final List<AuditAnswer> answers;
  final List<String> photos;
  final List<String> photoUrls;
  final AuditDetailLocation? location;
  final String? notes;
  final String status;
  final String? auditResult;
  final DateTime submittedAt;
  final DateTime createdAt;

  String get formattedDate => DateFormat('yyyy-MM-dd HH:mm').format(submittedAt);

  String get resultLabel {
    switch (auditResult) {
      case 'pass':
        return 'Амжилттай';
      case 'warning':
        return 'Анхааруулга';
      case 'fail':
        return 'Амжилтгүй';
      default:
        return auditResult ?? '-';
    }
  }

  factory AuditDetail.fromJson(Map<String, dynamic> json) {
    return AuditDetail(
      id: json['id']?.toString() ?? '',
      campaignId: json['campaign_id']?.toString() ?? '',
      campaignName: json['campaign_name']?.toString(),
      tradeshopId: json['tradeshop_id']?.toString() ?? '',
      tradeshopName: json['tradeshop_name']?.toString(),
      auditorId: json['auditor_id']?.toString() ?? '',
      auditorName: json['auditor_name']?.toString(),
      surveyId: json['survey_id']?.toString() ?? '',
      detectionId: json['detection_id']?.toString(),
      detectionSummary: (json['detection_summary'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
      detectionItems: (json['detection_items'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>()
              .map(DetectionItem.fromJson)
              .toList() ??
          const [],
      detectionTotal: (json['detection_total'] as num?)?.toInt() ?? 0,
      detectionProcessingTimeMs: (json['detection_processing_time_ms'] as num?)?.toDouble() ?? 0.0,
      answers: (json['answers'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>()
              .map(AuditAnswer.fromJson)
              .toList() ??
          const [],
      photos: (json['photos'] as List<dynamic>?)?.cast<String>() ?? const [],
      photoUrls: (json['photo_urls'] as List<dynamic>?)?.cast<String>() ?? const [],
      location: json['location'] != null
          ? AuditDetailLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? 'completed',
      auditResult: json['audit_result']?.toString(),
      submittedAt: DateTime.tryParse(json['submitted_at']?.toString() ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
