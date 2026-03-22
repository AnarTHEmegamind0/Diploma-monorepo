import 'package:core/core/app_theme.dart';
import 'package:core/core/widgets/neo_card.dart';
import 'package:core/features/audit/models/customer.dart';
import 'package:core/features/audit/providers/audit_provider.dart';
import 'package:core/features/audit/pages/map_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Customer (tradeshop) selection page – Figma node 2:333.
class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AuditProvider>();
      await provider.ensureCurrentLocation();
      await provider.loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final customers = provider.filteredCustomers;
    final groups = provider.availableGroups;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'Харилцагч сонгох',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.darkNavy, width: 2),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Хайх...',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Zone filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ZoneChip(
                      label: 'Бүгд',
                      isActive: provider.selectedGroupName.isEmpty,
                      onTap: () => provider.setSelectedGroupName(''),
                    ),
                    for (final group in groups) ...[
                      const SizedBox(width: 8),
                      _ZoneChip(
                        label: group,
                        isActive: provider.selectedGroupName == group,
                        onTap: () => provider.setSelectedGroupName(group),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer list
            Expanded(
              child: provider.customersLoading
                  ? const Center(child: CircularProgressIndicator())
                  : customers.isEmpty
                  ? Center(
                      child: Text(
                        'Харилцагч олдсонгүй',
                        style: GoogleFonts.inter(color: AppColors.textGrey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: customers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        return _CustomerCard(
                          customer: customers[i],
                          onTap: () async {
                            final provider = context.read<AuditProvider>();
                            final hasLocation = await provider
                                .ensureCurrentLocation(
                                  requestPermission: true,
                                );
                            if (!context.mounted) {
                              return;
                            }
                            if (!hasLocation) {
                              final message =
                                  provider.locationMessage ??
                                  'Таны байршлыг шалгаж чадсангүй.';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                              return;
                            }

                            await provider.loadCustomers();
                            if (!context.mounted) {
                              return;
                            }
                            final selectedCustomer = provider.customers
                                .cast<Customer?>()
                                .firstWhere(
                                  (item) => item?.id == customers[i].id,
                                  orElse: () => customers[i],
                                );
                            final customerToCheck =
                                selectedCustomer ?? customers[i];
                            final gate = provider.checkCustomerAccess(
                              customerToCheck,
                            );
                            if (!gate.canProceed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(gate.message)),
                              );
                              return;
                            }

                            provider.selectCustomer(customerToCheck);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MapPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  const _ZoneChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.orange : AppColors.white,
          border: Border.all(
            color: isActive ? AppColors.orange : AppColors.darkNavy,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.white : AppColors.darkNavy,
          ),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.onTap});
  final Customer customer;
  final VoidCallback onTap;

  Color get _avatarColor {
    final colors = [
      AppColors.orange,
      AppColors.teal,
      AppColors.yellow,
      const Color(0xFFAB47BC),
      const Color(0xFF42A5F5),
    ];
    return colors[customer.name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _avatarColor,
                border: Border.all(color: AppColors.darkNavy, width: 2),
              ),
              child: Center(
                child: Text(
                  customer.initials,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customer.address,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (customer.groupName.isNotEmpty)
                        Expanded(
                          child: Text(
                            customer.groupName,
                            style: GoogleFonts.syneMono(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (customer.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Дууссан',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Distance badge
            if (customer.distanceKm != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${customer.distanceKm!.toStringAsFixed(1)}km',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
