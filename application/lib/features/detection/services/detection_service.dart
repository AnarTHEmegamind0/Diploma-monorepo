import 'package:core/features/detection/models/detection_result.dart';
import 'package:core/features/detection/repositories/detection_repository.dart';

class DetectionService {
  DetectionService({required DetectionRepository detectionRepository})
    : _detectionRepository = detectionRepository;

  final DetectionRepository _detectionRepository;

  Future<DetectionResult> detect(String imagePath) {
    return _detectionRepository.detect(imagePath);
  }
}

class DetectionException implements Exception {
  DetectionException(this.message);
  final String message;

  @override
  String toString() => message;
}
