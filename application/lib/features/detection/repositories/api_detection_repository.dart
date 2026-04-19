import 'dart:io';

import 'package:core/features/detection/models/detection_result.dart';
import 'package:core/features/detection/repositories/detection_repository.dart';
import 'package:core/features/detection/services/detection_service.dart';
import 'package:dio/dio.dart';

class ApiDetectionRepository implements DetectionRepository {
  ApiDetectionRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<DetectionResult> detect(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw DetectionException('Image file not found: $imagePath');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    try {
      final response = await _dio.post(
        '/api/detection/detect',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        return DetectionResult.fromJson(response.data as Map<String, dynamic>);
      }

      throw DetectionException(
        'Detection failed with status ${response.statusCode}',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw DetectionException('Detection timeout. Please try again.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw DetectionException(
          'Cannot connect to server. Check your connection.',
        );
      }
      throw DetectionException(e.message ?? 'Detection failed');
    }
  }
}

class FakeDetectionRepository implements DetectionRepository {
  @override
  Future<DetectionResult> detect(String imagePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return DetectionResult(
      detectionId: 'fake-${DateTime.now().millisecondsSinceEpoch}',
      imagePath: imagePath,
      timestamp: DateTime.now().toIso8601String(),
      detections: [
        Detection(
          classId: 1,
          className: 'coca_cola_500ml',
          confidence: 0.95,
          bbox: [100, 100, 200, 300],
        ),
        Detection(
          classId: 1,
          className: 'coca_cola_500ml',
          confidence: 0.88,
          bbox: [220, 100, 320, 300],
        ),
        Detection(
          classId: 2,
          className: 'fanta_500ml',
          confidence: 0.92,
          bbox: [340, 100, 440, 300],
        ),
        Detection(
          classId: 3,
          className: 'sprite_500ml',
          confidence: 0.87,
          bbox: [460, 100, 560, 300],
        ),
      ],
      totalProducts: 4,
      processingTimeMs: 45,
    );
  }
}
