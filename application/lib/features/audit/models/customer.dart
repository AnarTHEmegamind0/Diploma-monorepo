/// A trade-shop / customer location from the API.
class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.address = '',
    this.groupName = '',
    this.categoryName = '',
    this.assignedAuditorName = '',
    this.auditStatus = 'pending',
    this.latestSubmittedAt,
    this.distanceKm,
    this.latitude,
    this.longitude,
    this.zone,
  });

  final String id;
  final String name;
  final String address;
  final String groupName;
  final String categoryName;
  final String assignedAuditorName;
  final String auditStatus;
  final DateTime? latestSubmittedAt;
  final double? distanceKm;
  final double? latitude;
  final double? longitude;
  final int? zone;

  bool get isCompleted => auditStatus == 'completed';

  Customer copyWith({
    double? distanceKm,
    DateTime? latestSubmittedAt,
  }) {
    return Customer(
      id: id,
      name: name,
      address: address,
      groupName: groupName,
      categoryName: categoryName,
      assignedAuditorName: assignedAuditorName,
      auditStatus: auditStatus,
      latestSubmittedAt: latestSubmittedAt ?? this.latestSubmittedAt,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude,
      longitude: longitude,
      zone: zone,
    );
  }

  /// Two-letter abbreviation used as avatar.
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    final groupName = json['group_name']?.toString() ?? '';
    return Customer(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      groupName: groupName,
      categoryName: json['category_name']?.toString() ?? '',
      assignedAuditorName: json['assigned_auditor_name']?.toString() ?? '',
      auditStatus: json['audit_status']?.toString() ?? 'pending',
      latestSubmittedAt: DateTime.tryParse(
        json['latest_submitted_at']?.toString() ?? '',
      ),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      latitude: (json['location']?['lat'] as num?)?.toDouble(),
      longitude: (json['location']?['lng'] as num?)?.toDouble(),
      zone: _deriveZone(groupName),
    );
  }

  static int? _deriveZone(String groupName) {
    const zoneMap = {
      'Улаанбаатар - Төв': 1,
      'Улаанбаатар - Баянзүрх': 2,
      'Дархан': 3,
      'Эрдэнэт': 4,
    };
    return zoneMap[groupName];
  }
}
