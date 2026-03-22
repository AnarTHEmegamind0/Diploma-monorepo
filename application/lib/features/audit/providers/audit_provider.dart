import 'package:core/features/audit/models/campaign.dart';
import 'package:core/features/audit/models/customer.dart';
import 'package:core/features/audit/services/audit_service.dart';
import 'package:core/features/audit/services/location_service.dart';
import 'package:core/features/history/models/audit_history_item.dart';
import 'package:flutter/foundation.dart';

class AuditProvider extends ChangeNotifier {
  AuditProvider({
    required AuditService auditService,
    required LocationService locationService,
  }) : _auditService = auditService,
       _locationService = locationService;

  final AuditService _auditService;
  final LocationService _locationService;

  bool _campaignsLoading = false;
  bool _customersLoading = false;
  bool _historyLoading = false;
  bool _locationLoading = false;
  bool _submitting = false;
  String? _error;
  String? _submitError;
  String? _lastSubmissionId;
  String? _submissionMessage;

  List<Campaign> _campaigns = [];
  Campaign? _selectedCampaign;
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  String _searchQuery = '';
  String _selectedGroupName = '';
  int _currentCategoryIndex = 0;
  final Map<String, dynamic> _questionAnswers = {};
  final Map<String, List<String>> _categoryImages = {};
  final Map<String, String> _categoryNotes = {};
  List<AuditHistoryItem> _history = [];
  double? _currentLatitude;
  double? _currentLongitude;
  double? _currentAccuracy;
  LocationCheckStatus _locationStatus = LocationCheckStatus.unknown;
  String? _locationMessage;

  bool get campaignsLoading => _campaignsLoading;
  bool get customersLoading => _customersLoading;
  bool get historyLoading => _historyLoading;
  bool get locationLoading => _locationLoading;
  bool get submitting => _submitting;
  String? get error => _error;
  String? get submitError => _submitError;
  String? get lastSubmissionId => _lastSubmissionId;
  String? get submissionMessage => _submissionMessage;

  List<Campaign> get campaigns => _campaigns;
  Campaign? get selectedCampaign => _selectedCampaign;
  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  String get searchQuery => _searchQuery;
  String get selectedGroupName => _selectedGroupName;
  int get currentCategoryIndex => _currentCategoryIndex;
  Map<String, List<String>> get categoryImages => _categoryImages;
  List<AuditHistoryItem> get history => _history;
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;
  double? get currentAccuracy => _currentAccuracy;
  LocationCheckStatus get locationStatus => _locationStatus;
  String? get locationMessage => _locationMessage;
  bool get hasCurrentLocation =>
      _currentLatitude != null && _currentLongitude != null;

  List<String> get availableGroups {
    final groups =
        _customers
            .map((item) => item.groupName)
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList();
    groups.sort();
    return groups;
  }

  AuditHistoryStats get historyStats => AuditHistoryStats.fromItems(_history);

  int get todayTaskCount =>
      _customers.where((customer) => !customer.isCompleted).length;

  int get completedTaskCount =>
      _customers.where((customer) => customer.isCompleted).length;

  int get totalTaskCount => _customers.length;

  List<Customer> get filteredCustomers {
    return _customers.where((customer) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.address.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGroup =
          _selectedGroupName.isEmpty || customer.groupName == _selectedGroupName;
      return matchesSearch && matchesGroup;
    }).toList();
  }

  CampaignCategory? get currentCategory {
    if (_selectedCampaign == null || _selectedCampaign!.categories.isEmpty) {
      return null;
    }
    if (_currentCategoryIndex >= _selectedCampaign!.categories.length) {
      return _selectedCampaign!.categories.last;
    }
    return _selectedCampaign!.categories[_currentCategoryIndex];
  }

  Future<bool> ensureCurrentLocation({bool requestPermission = false}) async {
    _locationLoading = true;
    notifyListeners();
    try {
      final result = await _locationService.checkCurrentLocation(
        requestPermission: requestPermission,
      );

      _locationStatus = result.status;
      _locationMessage = result.message;
      _currentLatitude = result.latitude;
      _currentLongitude = result.longitude;
      _currentAccuracy = result.accuracy;
      return result.isGranted;
    } catch (_) {
      _locationStatus = LocationCheckStatus.unavailable;
      _locationMessage = 'Байршил шалгах үед алдаа гарлаа. Дахин оролдоно уу.';
      _currentLatitude = null;
      _currentLongitude = null;
      _currentAccuracy = null;
      return false;
    } finally {
      _locationLoading = false;
      notifyListeners();
    }
  }

  LocationGateResult checkCustomerAccess(Customer customer) {
    return _locationService.evaluateCustomerAccess(
      customer: customer,
      currentLatitude: _currentLatitude,
      currentLongitude: _currentLongitude,
    );
  }

  Future<void> loadCampaigns() async {
    _campaignsLoading = true;
    _error = null;
    notifyListeners();
    try {
      _campaigns = await _auditService.fetchCampaigns();
    } catch (e) {
      _error = e.toString();
      _campaigns = [];
    } finally {
      _campaignsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomers({String? campaignId}) async {
    _customersLoading = true;
    _error = null;
    notifyListeners();
    try {
      _customers = await _auditService.fetchCustomers(
        campaignId: campaignId,
        currentLatitude: _currentLatitude,
        currentLongitude: _currentLongitude,
      );
    } catch (e) {
      _error = e.toString();
      _customers = [];
    } finally {
      _customersLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    _historyLoading = true;
    notifyListeners();
    try {
      _history = await _auditService.fetchHistory();
    } catch (e) {
      _error = e.toString();
      _history = [];
    } finally {
      _historyLoading = false;
      notifyListeners();
    }
  }

  List<Campaign> campaignsForSelectedCustomer() {
    final customerId = _selectedCustomer?.id;
    if (customerId == null) return _campaigns;
    return _campaigns
        .where((campaign) => campaign.tradeshopIds.contains(customerId))
        .toList();
  }

  void selectCampaign(Campaign campaign) {
    _selectedCampaign = campaign;
    _currentCategoryIndex = 0;
    _questionAnswers.clear();
    _categoryImages.clear();
    _categoryNotes.clear();
    _submitError = null;
    _lastSubmissionId = null;
    _submissionMessage = null;
    notifyListeners();
  }

  void selectCustomer(Customer customer) {
    _selectedCustomer = customer;
    _selectedCampaign = null;
    _currentCategoryIndex = 0;
    _questionAnswers.clear();
    _categoryImages.clear();
    _categoryNotes.clear();
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setSelectedGroupName(String value) {
    _selectedGroupName = value;
    notifyListeners();
  }

  void setCurrentCategoryIndex(int index) {
    _currentCategoryIndex = index;
    notifyListeners();
  }

  dynamic answerFor(String questionId) => _questionAnswers[questionId];

  void setAnswer(String questionId, dynamic value) {
    _questionAnswers[questionId] = value;
    notifyListeners();
  }

  void addImage(String categoryId, String path) {
    _categoryImages.putIfAbsent(categoryId, () => <String>[]);
    _categoryImages[categoryId]!.add(path);
    notifyListeners();
  }

  void removeImage(String categoryId, int index) {
    final list = _categoryImages[categoryId];
    if (list == null || index < 0 || index >= list.length) {
      return;
    }
    list.removeAt(index);
    notifyListeners();
  }

  void setCategoryNote(String categoryId, String value) {
    _categoryNotes[categoryId] = value;
    notifyListeners();
  }

  String categoryNote(String categoryId) => _categoryNotes[categoryId] ?? '';

  bool isCategoryComplete(CampaignCategory category) {
    for (final question in category.questions) {
      if (question.type == 'photo') {
        continue;
      }
      if (!question.required) {
        continue;
      }
      final answer = _questionAnswers[question.id];
      if (answer == null) {
        return false;
      }
      if (answer is String && answer.trim().isEmpty) {
        return false;
      }
      if (answer is List && answer.isEmpty) {
        return false;
      }
    }

    if (category.hasImage &&
        (_categoryImages[category.id]?.isEmpty ?? true)) {
      return false;
    }
    return true;
  }

  bool get canMoveNext {
    final category = currentCategory;
    if (category == null) return false;
    return isCategoryComplete(category);
  }

  void goToNextCategory() {
    if (_selectedCampaign == null) return;
    if (_currentCategoryIndex < _selectedCampaign!.categories.length - 1) {
      _currentCategoryIndex++;
      notifyListeners();
    }
  }

  void goToPreviousCategory() {
    if (_currentCategoryIndex == 0) return;
    _currentCategoryIndex--;
    notifyListeners();
  }

  Future<bool> submitAudit() async {
    final campaign = _selectedCampaign;
    final customer = _selectedCustomer;
    if (campaign == null || customer == null) {
      _submitError = 'Кампанит ажил эсвэл дэлгүүр сонгогдоогүй байна.';
      notifyListeners();
      return false;
    }

    final photoPaths = _categoryImages.values.expand((paths) => paths).toList();
    if (photoPaths.isEmpty) {
      _submitError = 'Дор хаяж нэг зураг нэмнэ үү.';
      notifyListeners();
      return false;
    }

    _submitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final response = await _auditService.submitAudit(
        campaignId: campaign.id,
        tradeshopId: customer.id,
        answers: _questionAnswers,
        photoPaths: photoPaths,
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        accuracy: _currentAccuracy,
        notes: _categoryNotes.values.where((note) => note.trim().isNotEmpty).join('\n'),
      );

      _lastSubmissionId = response['audit_response_id']?.toString();
      _submissionMessage =
          response['message']?.toString() ?? 'Аудит амжилттай илгээгдлээ.';

      await loadCustomers();
      await loadHistory();
      return true;
    } catch (e) {
      _submitError = e.toString();
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void resetAudit() {
    _selectedCampaign = null;
    _selectedCustomer = null;
    _currentCategoryIndex = 0;
    _questionAnswers.clear();
    _categoryImages.clear();
    _categoryNotes.clear();
    _submitError = null;
    _lastSubmissionId = null;
    _submissionMessage = null;
    notifyListeners();
  }
}
