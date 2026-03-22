class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    this.description,
    this.surveyId,
    this.surveyName,
    this.startDate,
    this.endDate,
    this.progressPercent = 0,
    this.totalTradeshops = 0,
    this.completedTradeshops = 0,
    this.pendingTradeshops = 0,
    this.tradeshopIds = const [],
    this.categories = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? surveyId;
  final String? surveyName;
  final DateTime? startDate;
  final DateTime? endDate;
  final double progressPercent;
  final int totalTradeshops;
  final int completedTradeshops;
  final int pendingTradeshops;
  final List<String> tradeshopIds;
  final List<CampaignCategory> categories;

  int get categoryCount => categories.length;
  int get questionCount =>
      categories.fold<int>(0, (sum, category) => sum + category.questionCount);

  Campaign copyWith({
    String? id,
    String? name,
    String? description,
    String? surveyId,
    String? surveyName,
    DateTime? startDate,
    DateTime? endDate,
    double? progressPercent,
    int? totalTradeshops,
    int? completedTradeshops,
    int? pendingTradeshops,
    List<String>? tradeshopIds,
    List<CampaignCategory>? categories,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      surveyId: surveyId ?? this.surveyId,
      surveyName: surveyName ?? this.surveyName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progressPercent: progressPercent ?? this.progressPercent,
      totalTradeshops: totalTradeshops ?? this.totalTradeshops,
      completedTradeshops: completedTradeshops ?? this.completedTradeshops,
      pendingTradeshops: pendingTradeshops ?? this.pendingTradeshops,
      tradeshopIds: tradeshopIds ?? this.tradeshopIds,
      categories: categories ?? this.categories,
    );
  }

  factory Campaign.fromJson(
    Map<String, dynamic> json, {
    List<CampaignCategory> categories = const [],
  }) {
    final tradeshops =
        (json['tradeshops'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .map((item) => item['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList() ??
        (json['target_tradeshop_ids'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        const <String>[];

    return Campaign(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      surveyId: json['survey_id']?.toString(),
      surveyName: json['survey_name']?.toString(),
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0,
      totalTradeshops: json['total_tradeshops'] as int? ?? tradeshops.length,
      completedTradeshops: json['completed_tradeshops'] as int? ?? 0,
      pendingTradeshops: json['pending_tradeshops'] as int? ?? 0,
      tradeshopIds: tradeshops,
      categories: categories,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class CampaignCategory {
  const CampaignCategory({
    required this.id,
    required this.name,
    this.description,
    this.questionCount = 0,
    this.hasImage = false,
    this.questions = const [],
  });

  final String id;
  final String name;
  final String? description;
  final int questionCount;
  final bool hasImage;
  final List<CategoryQuestion> questions;

  factory CampaignCategory.fromSurveyGroup(Map<String, dynamic> json) {
    final questions =
        (json['questions'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .map(CategoryQuestion.fromJson)
            .toList() ??
        const <CategoryQuestion>[];

    return CampaignCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      questionCount: json['question_count'] as int? ?? questions.length,
      hasImage: questions.any((question) => question.type == 'photo'),
      questions: questions,
    );
  }
}

class CategoryQuestion {
  const CategoryQuestion({
    required this.id,
    required this.label,
    this.type = 'text',
    this.required = true,
    this.options = const [],
    this.detectionBased = false,
    this.productClass,
  });

  final String id;
  final String label;
  final String type;
  final bool required;
  final List<String> options;
  final bool detectionBased;
  final String? productClass;

  bool get isNumeric => type == 'number' || type == 'rating';

  factory CategoryQuestion.fromJson(Map<String, dynamic> json) {
    return CategoryQuestion(
      id: json['id']?.toString() ?? '',
      label: json['text']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      required: json['required'] != false,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
      detectionBased: json['detection_based'] == true,
      productClass: json['product_class']?.toString(),
    );
  }
}
