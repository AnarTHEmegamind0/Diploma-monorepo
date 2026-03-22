import 'dart:io' show Platform;

import 'package:core/core/app_theme.dart';
import 'package:core/core/widgets/neo_button.dart';
import 'package:core/core/widgets/neo_card.dart';
import 'package:core/features/audit/pages/campaign_page.dart';
import 'package:core/features/audit/providers/audit_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  static const LatLng fallbackCenter = LatLng(47.9185, 106.9177);
  static const double allowedRadiusKm = 5;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AuditProvider>();
      if (provider.currentLatitude == null ||
          provider.currentLongitude == null) {
        provider.ensureCurrentLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final customer = provider.selectedCustomer;
    final hasStoreCoordinates =
        customer?.latitude != null && customer?.longitude != null;
    final hasCurrentLocation =
        provider.currentLatitude != null && provider.currentLongitude != null;
    final storeLocation = hasStoreCoordinates
        ? LatLng(customer!.latitude!, customer.longitude!)
        : MapPage.fallbackCenter;
    final distanceKm = _distanceToStore(provider);
    final isWithinRadius =
        distanceKm != null && distanceKm <= MapPage.allowedRadiusKm;
    final mapAvailable = kIsWeb || Platform.isAndroid || Platform.isIOS;

    final mapMarkers = <Marker>{
      Marker(
        markerId: const MarkerId('selected_store'),
        position: storeLocation,
        infoWindow: InfoWindow(
          title: customer?.name ?? 'Сонгосон дэлгүүр',
          snippet: customer?.address ?? 'Байршлын мэдээлэл байхгүй',
        ),
      ),
      if (hasCurrentLocation)
        Marker(
          markerId: const MarkerId('auditor_location'),
          position: LatLng(
            provider.currentLatitude!,
            provider.currentLongitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'Миний байршил'),
        ),
    };

    final storeCircles = <Circle>{
      if (hasStoreCoordinates)
        Circle(
          circleId: const CircleId('entry_radius'),
          center: storeLocation,
          radius: MapPage.allowedRadiusKm * 1000,
          fillColor: AppColors.teal.withValues(alpha: 0.12),
          strokeColor: AppColors.teal,
          strokeWidth: 2,
        ),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: AppColors.darkNavy,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Буцах',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 240,
                  child: mapAvailable
                      ? GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: storeLocation,
                            zoom: hasStoreCoordinates ? 14.8 : 11,
                          ),
                          markers: mapMarkers,
                          circles: storeCircles,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          compassEnabled: true,
                        )
                      : _MapUnavailable(
                          hasStoreCoordinates: hasStoreCoordinates,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NeoCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer?.name ?? 'Дэлгүүр сонгогдоогүй',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer?.address ?? 'Хаяг бүртгэгдээгүй байна.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer?.groupName ?? 'Бүс тодорхойгүй',
                      style: GoogleFonts.syneMono(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.lightGrey),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.navigation,
                      label: 'Зай',
                      value: _distanceLabel(
                        provider: provider,
                        hasStoreCoordinates: hasStoreCoordinates,
                        distanceKm: distanceKm,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Нэвтрэх нөхцөл',
                      value: '5 км дотор',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(
                          provider: provider,
                          hasStoreCoordinates: hasStoreCoordinates,
                          hasCurrentLocation: hasCurrentLocation,
                          isWithinRadius: isWithinRadius,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _statusIcon(
                              provider: provider,
                              hasStoreCoordinates: hasStoreCoordinates,
                              hasCurrentLocation: hasCurrentLocation,
                              isWithinRadius: isWithinRadius,
                            ),
                            color: AppColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusText(
                                provider: provider,
                                hasStoreCoordinates: hasStoreCoordinates,
                                hasCurrentLocation: hasCurrentLocation,
                                isWithinRadius: isWithinRadius,
                                distanceKm: distanceKm,
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NeoButton(
                label: provider.locationLoading
                    ? 'Байршил шалгаж байна...'
                    : isWithinRadius
                    ? 'Аудит эхлүүлэх'
                    : '5 км дотор очоод эхлүүлнэ',
                backgroundColor: isWithinRadius
                    ? AppColors.teal
                    : AppColors.grey.withValues(alpha: 0.4),
                borderColor: AppColors.darkNavy,
                onPressed: (!isWithinRadius || provider.locationLoading)
                    ? null
                    : () {
                        context.read<AuditProvider>().loadCampaigns();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CampaignPage(),
                          ),
                        );
                      },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  isWithinRadius
                      ? 'Та ${customer?.name ?? 'сонгосон дэлгүүр'}-ийн бүсэд орсон байна'
                      : 'Аудит эхлүүлэхийн тулд дэлгүүрээс 5 км дотор байх шаардлагатай',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _distanceToStore(AuditProvider provider) {
    final customer = provider.selectedCustomer;
    if (customer?.latitude == null || customer?.longitude == null) {
      return customer?.distanceKm;
    }
    if (provider.currentLatitude == null || provider.currentLongitude == null) {
      return customer?.distanceKm;
    }

    return Geolocator.distanceBetween(
          provider.currentLatitude!,
          provider.currentLongitude!,
          customer!.latitude!,
          customer.longitude!,
        ) /
        1000;
  }

  String _distanceLabel({
    required AuditProvider provider,
    required bool hasStoreCoordinates,
    required double? distanceKm,
  }) {
    if (provider.locationLoading) {
      return 'Шалгаж байна';
    }
    if (!hasStoreCoordinates) {
      return 'Байршил дутуу';
    }
    if (distanceKm == null) {
      return 'Тодорхойгүй';
    }
    if (distanceKm <= MapPage.allowedRadiusKm) {
      return 'Орсон байна';
    }
    return '${distanceKm.toStringAsFixed(1)} км';
  }

  String _statusText({
    required AuditProvider provider,
    required bool hasStoreCoordinates,
    required bool hasCurrentLocation,
    required bool isWithinRadius,
    required double? distanceKm,
  }) {
    if (provider.locationLoading) {
      return 'Таны байршлыг шалгаж байна';
    }
    if (!hasStoreCoordinates) {
      return 'Энэ дэлгүүрт байршлын мэдээлэл дутуу байна';
    }
    if (!hasCurrentLocation) {
      return 'Таны байршлыг авах зөвшөөрөл шаардлагатай';
    }
    if (isWithinRadius) {
      return 'Та дэлгүүрийн 5 км радиус дотор орсон байна';
    }
    if (distanceKm == null) {
      return 'Дэлгүүр хүртэлх зайг тодорхойлж чадсангүй';
    }
    return 'Та дэлгүүрээс ${distanceKm.toStringAsFixed(1)} км зайтай байна';
  }

  Color _statusColor({
    required AuditProvider provider,
    required bool hasStoreCoordinates,
    required bool hasCurrentLocation,
    required bool isWithinRadius,
  }) {
    if (provider.locationLoading) {
      return AppColors.orange;
    }
    if (hasStoreCoordinates && hasCurrentLocation && isWithinRadius) {
      return AppColors.teal;
    }
    return AppColors.orange;
  }

  IconData _statusIcon({
    required AuditProvider provider,
    required bool hasStoreCoordinates,
    required bool hasCurrentLocation,
    required bool isWithinRadius,
  }) {
    if (provider.locationLoading) {
      return Icons.hourglass_top_rounded;
    }
    if (hasStoreCoordinates && hasCurrentLocation && isWithinRadius) {
      return Icons.check_circle;
    }
    return Icons.warning_amber_rounded;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.orange, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkNavy,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkNavy,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapUnavailable extends StatelessWidget {
  const _MapUnavailable({required this.hasStoreCoordinates});

  final bool hasStoreCoordinates;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 44, color: AppColors.darkNavy),
            const SizedBox(height: 12),
            Text(
              hasStoreCoordinates
                  ? 'Google Maps энэ платформ дээр дэмжигдэхгүй байна'
                  : 'Координат байхгүй тул map харуулах боломжгүй',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.darkNavy),
            ),
          ],
        ),
      ),
    );
  }
}
