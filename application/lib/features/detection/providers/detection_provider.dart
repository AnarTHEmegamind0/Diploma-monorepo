import 'package:core/features/detection/models/detection_result.dart';
import 'package:core/features/detection/services/detection_service.dart';
import 'package:flutter/foundation.dart';

class DetectionProvider extends ChangeNotifier {
  DetectionProvider({required DetectionService detectionService})
    : _detectionService = detectionService;

  final DetectionService _detectionService;

  bool _isLoading = false;
  DetectionResult? _result;
  String? _error;

  bool get isLoading => _isLoading;
  DetectionResult? get result => _result;
  String? get error => _error;

  Future<DetectionResult?> detect(String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _detectionService.detect(imagePath);
      _result = result;
      return result;
    } on DetectionException catch (e) {
      _result = null;
      _error = e.message;
      return null;
    } catch (e) {
      _result = null;
      _error = 'Detection алдаа: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResult() {
    if (_result == null) {
      return;
    }
    _result = null;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }

  void reset() {
    if (!_isLoading && _result == null && _error == null) {
      return;
    }
    _isLoading = false;
    _result = null;
    _error = null;
    notifyListeners();
  }
}
