import 'dart:convert';

import 'package:core/core/dio_client.dart';
import 'package:core/features/audit/models/campaign.dart';
import 'package:core/features/audit/models/customer.dart';
import 'package:core/features/history/models/audit_history_item.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class AuditService {
  AuditService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  final Dio _dio;

  Future<List<Campaign>> fetchCampaigns() async {
    final response = await _dio.get<List<dynamic>>('/mobile/campaigns');
    final items = response.data ?? const [];

    final campaigns = await Future.wait(
      items.map((item) async {
        final summary = item as Map<String, dynamic>;
        final campaignId = summary['id']?.toString() ?? '';
        final detailResponse = await _dio.get<Map<String, dynamic>>(
          '/mobile/campaigns/$campaignId',
        );
        final surveyResponse = await _dio.get<Map<String, dynamic>>(
          '/mobile/campaigns/$campaignId/survey',
        );

        final categories =
            (surveyResponse.data?['groups'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(CampaignCategory.fromSurveyGroup)
                .toList() ??
            const <CampaignCategory>[];

        return Campaign.fromJson(
          detailResponse.data ?? summary,
          categories: categories,
        );
      }),
    );

    campaigns.sort((a, b) => a.name.compareTo(b.name));
    return campaigns;
  }

  Future<List<Customer>> fetchCustomers({
    String? campaignId,
    double? currentLatitude,
    double? currentLongitude,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/mobile/tradeshops',
      queryParameters: {
        if (campaignId != null && campaignId.isNotEmpty) 'campaign_id': campaignId,
      },
    );

    return (response.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Customer.fromJson)
        .map(
          (customer) => customer.copyWith(
            distanceKm: _calculateDistanceKm(
              currentLatitude: currentLatitude,
              currentLongitude: currentLongitude,
              customer: customer,
            ),
          ),
        )
        .toList()
      ..sort((a, b) {
          final left = a.distanceKm ?? 999999;
          final right = b.distanceKm ?? 999999;
          return left.compareTo(right);
        });
  }

  Future<List<AuditHistoryItem>> fetchHistory({
    String? campaignId,
    String? tradeshopId,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/mobile/audits/my',
      queryParameters: {
        if (campaignId != null && campaignId.isNotEmpty) 'campaign_id': campaignId,
        if (tradeshopId != null && tradeshopId.isNotEmpty) 'tradeshop_id': tradeshopId,
      },
    );

    return (response.data ?? const [])
        .cast<Map<String, dynamic>>()
        .map(AuditHistoryItem.fromJson)
        .toList();
  }

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
    final serializedAnswers =
        answers.entries
            .where((entry) => entry.value != null)
            .map((entry) => {'question_id': entry.key, 'answer': entry.value})
            .toList();

    final formData = FormData.fromMap({
      'campaign_id': campaignId,
      'tradeshop_id': tradeshopId,
      if (latitude != null) 'lat': latitude.toString(),
      if (longitude != null) 'lng': longitude.toString(),
      if (accuracy != null) 'accuracy': accuracy.toString(),
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (serializedAnswers.isNotEmpty) 'answers_json': jsonEncode(serializedAnswers),
    });

    for (final path in photoPaths) {
      formData.files.add(
        MapEntry(
          'photos',
          await MultipartFile.fromFile(path),
        ),
      );
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/audit-submit/submit',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.data ?? const <String, dynamic>{};
  }

  static double? _calculateDistanceKm({
    required double? currentLatitude,
    required double? currentLongitude,
    required Customer customer,
  }) {
    if (currentLatitude == null ||
        currentLongitude == null ||
        customer.latitude == null ||
        customer.longitude == null) {
      return customer.distanceKm;
    }

    final meters = Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      customer.latitude!,
      customer.longitude!,
    );
    return meters / 1000;
  }
}
