import 'package:core/features/detection/models/detection_result.dart';

abstract interface class DetectionRepository {
  Future<DetectionResult> detect(String imagePath);
}
