import 'package:core/features/audit/models/campaign.dart';
import 'package:core/features/audit/models/customer.dart';
import 'package:core/features/audit/services/audit_service.dart';
import 'package:core/features/history/models/audit_detail.dart';
import 'package:core/features/history/models/audit_history_item.dart';
import 'package:dio/dio.dart';

class FakeAuditService extends AuditService {
  FakeAuditService() : super(dio: Dio());

  @override
  Future<List<Campaign>> fetchCampaigns() async {
    return const [
      Campaign(
        id: 'campaign_demo_1',
        name: '2026 Хаврын ундааны аудит',
        description: 'Cash zone, хөргөгч, үндсэн лангуу шалгана.',
        surveyId: 'survey_demo_1',
        surveyName: 'Ундааны аудит',
        progressPercent: 50,
        totalTradeshops: 2,
        completedTradeshops: 1,
        pendingTradeshops: 1,
        tradeshopIds: ['shop_1', 'shop_2'],
        categories: [
          CampaignCategory(
            id: 'group_cash_zone',
            name: 'Cash zone',
            description: 'Кассын орчны өрөлт, шошго, facing шалгалт.',
            questionCount: 3,
            questions: [
              CategoryQuestion(
                id: 'q_cash_yes_no',
                label: 'Cash zone байна уу?',
                type: 'yes_no',
              ),
              CategoryQuestion(
                id: 'q_cash_count',
                label: 'Хэдэн бүтээгдэхүүн байна вэ?',
                type: 'number',
              ),
              CategoryQuestion(
                id: 'q_cash_label',
                label: 'Үнийн шошго байрласан эсэх',
                type: 'single_choice',
                options: ['Бүрэн', 'Хэсэгчлэн', 'Байхгүй'],
              ),
            ],
          ),
          CampaignCategory(
            id: 'group_fridge',
            name: 'Хөргөгч',
            description: 'Хөргөгчийн тоо, байршил, зураг.',
            questionCount: 2,
            hasImage: true,
            questions: [
              CategoryQuestion(
                id: 'q_fridge_yes_no',
                label: 'Хөргөгч бүртгэл хийгдсэн үү?',
                type: 'yes_no',
              ),
              CategoryQuestion(
                id: 'q_fridge_count',
                label: 'Хөргөгчийн тоо',
                type: 'number',
                detectionBased: true,
                productClass: 'fridge',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Future<List<Customer>> fetchCustomers({
    String? campaignId,
    double? currentLatitude,
    double? currentLongitude,
  }) async {
    return const [
      Customer(
        id: 'shop_1',
        name: 'GS25 Peace Mall',
        address: 'СБД, 1-р хороо, Peace Mall',
        groupName: 'Улаанбаатар - Төв',
        categoryName: 'Ундаа',
        assignedAuditorName: 'Demo Auditor',
        auditStatus: 'pending',
        distanceKm: 0.8,
        latitude: 47.9186,
        longitude: 106.9176,
      ),
      Customer(
        id: 'shop_2',
        name: 'CU Sansar',
        address: 'БЗД, 4-р хороо, Сансар',
        groupName: 'Улаанбаатар - Баянзүрх',
        categoryName: 'Ундаа',
        assignedAuditorName: 'Demo Auditor',
        auditStatus: 'completed',
        distanceKm: 2.4,
        latitude: 47.9215,
        longitude: 106.9459,
      ),
    ];
  }

  @override
  Future<List<AuditHistoryItem>> fetchHistory({
    String? campaignId,
    String? tradeshopId,
  }) async {
    return [
      AuditHistoryItem(
        id: 'audit_1',
        title: '2026 Хаврын ундааны аудит',
        location: 'CU Sansar',
        submittedAt: DateTime.now().subtract(const Duration(hours: 4)),
        status: AuditStatus.sent,
        answerCount: 6,
        detectionCount: 12,
      ),
      AuditHistoryItem(
        id: 'audit_2',
        title: '2026 Хаврын ундааны аудит',
        location: 'GS25 Peace Mall',
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: AuditStatus.sent,
        answerCount: 5,
        detectionCount: 9,
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>> submitAudit({
    required String campaignId,
    required String tradeshopId,
    required Map<String, dynamic> answers,
    required List<String> photoPaths,
    required double? latitude,
    required double? longitude,
    required double? accuracy,
    String? notes,
  }) async {
    return <String, dynamic>{
      'audit_response_id': 'demo-submission-001',
      'message': 'Аудит амжилттай илгээгдлээ.',
    };
  }

  @override
  Future<AuditDetail> fetchAuditDetail(String auditId) async {
    return AuditDetail(
      id: auditId,
      campaignId: 'campaign_demo_1',
      campaignName: '2026 Хаврын ундааны аудит',
      tradeshopId: 'shop_1',
      tradeshopName: 'GS25 Peace Mall',
      auditorId: 'auditor_1',
      auditorName: 'Demo Auditor',
      surveyId: 'survey_demo_1',
      detectionId: 'detection_1',
      detectionSummary: {'coca_cola': 5, 'fanta': 3, 'sprite': 2},
      detectionItems: const [
        DetectionItem(className: 'coca_cola', confidence: 0.95),
        DetectionItem(className: 'fanta', confidence: 0.88),
      ],
      detectionTotal: 10,
      detectionProcessingTimeMs: 245.5,
      answers: const [
        AuditAnswer(
          questionId: 'q1',
          questionText: 'Cash zone байна уу?',
          answer: 'Тийм',
          autoAnswered: true,
        ),
        AuditAnswer(
          questionId: 'q2',
          questionText: 'Хэдэн бүтээгдэхүүн байна вэ?',
          answer: 10,
          autoAnswered: true,
        ),
      ],
      photos: const ['demo.jpg'],
      photoUrls: const ['https://via.placeholder.com/400x300'],
      location: const AuditDetailLocation(lat: 47.9186, lng: 106.9176, accuracy: 10.5),
      notes: 'Demo тэмдэглэл',
      status: 'completed',
      auditResult: 'pass',
      submittedAt: DateTime.now().subtract(const Duration(hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    );
  }
}
