/// Detection result model from YOLO backend.
class DetectionResult {
  DetectionResult({
    required this.detectionId,
    required this.imagePath,
    required this.timestamp,
    required this.detections,
    required this.totalProducts,
    required this.processingTimeMs,
    this.message,
  });

  final String detectionId;
  final String imagePath;
  final String timestamp;
  final List<Detection> detections;
  final int totalProducts;
  final int processingTimeMs;
  final String? message;

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      detectionId: json['detection_id']?.toString() ?? '',
      imagePath: json['image_path']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      detections: (json['detections'] as List? ?? [])
          .map((d) => Detection.fromJson(d as Map<String, dynamic>))
          .toList(),
      totalProducts: json['total_products'] as int? ?? 0,
      processingTimeMs: json['processing_time_ms'] as int? ?? 0,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detection_id': detectionId,
      'image_path': imagePath,
      'timestamp': timestamp,
      'detections': detections.map((d) => d.toJson()).toList(),
      'total_products': totalProducts,
      'processing_time_ms': processingTimeMs,
      if (message != null) 'message': message,
    };
  }

  /// Count detections by class name.
  int countByClass(String className) {
    return detections.where((d) => d.className == className).length;
  }

  /// Get product counts grouped by class.
  Map<String, int> get productCounts {
    final counts = <String, int>{};
    for (final detection in detections) {
      counts[detection.className] = (counts[detection.className] ?? 0) + 1;
    }
    return counts;
  }

  /// Average confidence of all detections.
  double get averageConfidence {
    if (detections.isEmpty) return 0;
    final sum = detections.fold<double>(0, (sum, d) => sum + d.confidence);
    return sum / detections.length;
  }

  /// Check if model was loaded.
  bool get isModelLoaded => message == null || !message!.contains('not loaded');
}

/// Single detection (bounding box + class + confidence).
class Detection {
  Detection({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.bbox,
  });

  final int classId;
  final String className;
  final double confidence;
  final List<double> bbox; // [x1, y1, x2, y2]

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      classId: json['class_id'] as int? ?? 0,
      className: json['class_name']?.toString() ?? 'unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      bbox: (json['bbox'] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
      'confidence': confidence,
      'bbox': bbox,
    };
  }

  /// Human-readable class name (remove underscores, capitalize).
  String get displayName {
    return className
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  /// Confidence as percentage string.
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}
