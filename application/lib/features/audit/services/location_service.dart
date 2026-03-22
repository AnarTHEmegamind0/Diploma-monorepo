import 'package:core/features/audit/models/customer.dart';
import 'package:geolocator/geolocator.dart';

enum LocationCheckStatus {
  unknown,
  granted,
  denied,
  deniedForever,
  disabled,
  unavailable,
}

class LocationCheckResult {
  const LocationCheckResult({
    required this.status,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.message,
  });

  final LocationCheckStatus status;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? message;

  bool get isGranted =>
      status == LocationCheckStatus.granted &&
      latitude != null &&
      longitude != null;
}

class LocationGateResult {
  const LocationGateResult({
    required this.canProceed,
    required this.message,
    this.distanceKm,
  });

  final bool canProceed;
  final String message;
  final double? distanceKm;
}

class LocationService {
  Future<LocationCheckResult> checkCurrentLocation({
    bool requestPermission = false,
  }) async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      return const LocationCheckResult(
        status: LocationCheckStatus.disabled,
        message: 'Байршлын service унтраалттай байна. GPS-ээ асаана уу.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationCheckResult(
        status: LocationCheckStatus.denied,
        message: 'Байршлын зөвшөөрөл шаардлагатай байна.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationCheckResult(
        status: LocationCheckStatus.deniedForever,
        message: 'Байршлын зөвшөөрөл хаагдсан байна. App settings-ээс нээнэ үү.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LocationCheckResult(
      status: LocationCheckStatus.granted,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
    );
  }

  double? distanceKmToCustomer({
    required Customer customer,
    required double? currentLatitude,
    required double? currentLongitude,
  }) {
    if (currentLatitude == null ||
        currentLongitude == null ||
        customer.latitude == null ||
        customer.longitude == null) {
      return null;
    }

    final meters = Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      customer.latitude!,
      customer.longitude!,
    );
    return meters / 1000;
  }

  LocationGateResult evaluateCustomerAccess({
    required Customer customer,
    required double? currentLatitude,
    required double? currentLongitude,
    double allowedRadiusKm = 5,
  }) {
    if (customer.latitude == null || customer.longitude == null) {
      return const LocationGateResult(
        canProceed: false,
        message: 'Энэ дэлгүүрийн байршлын мэдээлэл дутуу байна.',
      );
    }

    if (currentLatitude == null || currentLongitude == null) {
      return const LocationGateResult(
        canProceed: false,
        message: 'Таны байршлыг авч чадсангүй. Дахин шалгана уу.',
      );
    }

    final distanceKm = distanceKmToCustomer(
      customer: customer,
      currentLatitude: currentLatitude,
      currentLongitude: currentLongitude,
    );

    if (distanceKm == null) {
      return const LocationGateResult(
        canProceed: false,
        message: 'Дэлгүүр хүртэлх зайг тодорхойлж чадсангүй.',
      );
    }

    if (distanceKm > allowedRadiusKm) {
      return LocationGateResult(
        canProceed: false,
        distanceKm: distanceKm,
        message:
            'Та ${customer.name}-ээс ${distanceKm.toStringAsFixed(1)} км зайтай байна. 5 км дотор очоод үргэлжлүүлнэ үү.',
      );
    }

    return LocationGateResult(
      canProceed: true,
      distanceKm: distanceKm,
      message: 'Байршил баталгаажлаа.',
    );
  }
}
