import 'package:core/core/app_theme.dart';
import 'package:core/core/widgets/neo_button.dart';
import 'package:core/core/widgets/neo_card.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      if (provider.profile == null && !provider.isLoading) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthProvider p) => p.user);
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Профайл',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 24),
              NeoCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkNavy, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          (user?.name ?? 'U')[0].toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile?.displayName ?? user?.name ?? 'Хэрэглэгч',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.email ?? user?.email ?? user?.phone ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (profile != null)
                NeoCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _ProfileInfoRow(label: 'Нэр', value: profile.displayName),
                      const Divider(height: 24, color: AppColors.lightGrey),
                      _ProfileInfoRow(label: 'Утас', value: profile.phone),
                      const Divider(height: 24, color: AppColors.lightGrey),
                      _ProfileInfoRow(
                        label: 'Имэйл',
                        value: profile.email ?? 'Бүртгэгдээгүй',
                      ),
                      const Divider(height: 24, color: AppColors.lightGrey),
                      _ProfileInfoRow(
                        label: 'Бүс',
                        value: profile.groupName ?? user?.groupName ?? '-',
                      ),
                      const Divider(height: 24, color: AppColors.lightGrey),
                      _ProfileInfoRow(label: 'Эрх', value: profile.roleLabel),
                    ],
                  ),
                ),
              if (profile == null && !profileProvider.isLoading) ...[
                NeoButton(
                  label: 'Мэдээлэл ачаалах',
                  backgroundColor: AppColors.darkNavy,
                  onPressed: profileProvider.load,
                ),
                const SizedBox(height: 16),
              ],
              if (profileProvider.error != null) ...[
                Text(
                  profileProvider.error!,
                  style: GoogleFonts.inter(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (profileProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              const SizedBox(height: 24),
              NeoButton(
                label: 'Гарах',
                backgroundColor: AppColors.red,
                onPressed: () => context.read<AuthProvider>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkNavy,
            ),
          ),
        ),
      ],
    );
  }
}
