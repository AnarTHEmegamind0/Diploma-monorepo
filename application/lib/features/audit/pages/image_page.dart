import 'dart:io';
import 'package:core/core/app_theme.dart';
import 'package:core/core/widgets/neo_button.dart';
import 'package:core/core/widgets/neo_card.dart';
import 'package:core/features/audit/providers/audit_provider.dart';
import 'package:core/features/audit/pages/thank_you_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// Image capture page – Figma nodes 2:843 (empty) & 2:889 (with images).
class ImagePage extends StatefulWidget {
  const ImagePage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<AuditProvider>();
    _notesController.text = provider.categoryNote(widget.categoryId);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image != null && mounted) {
      context.read<AuditProvider>().addImage(widget.categoryId, image.path);
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null && mounted) {
      context.read<AuditProvider>().addImage(widget.categoryId, image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final images = provider.categoryImages[widget.categoryId] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                widget.categoryName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                'Зургуудаа нэмээд илгээнэ үү',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(child: _buildContent(images, provider)),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.lightGrey, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Камер'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _takePhoto();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Галлерей'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickFromGallery();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(
                            color: AppColors.darkNavy,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              size: 20,
                              color: AppColors.darkNavy,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Зураг дарах',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      height: 48,
                      label: provider.submitting
                          ? 'Илгээж байна...'
                          : 'Илгээх (${images.length})',
                      icon: Icons.upload,
                      backgroundColor: images.isEmpty
                          ? AppColors.grey.withValues(alpha: 0.3)
                          : AppColors.orange,
                      isLoading: provider.submitting,
                      onPressed: images.isEmpty
                          ? null
                          : () async {
                              final navigator = Navigator.of(context);
                              provider.setCategoryNote(
                                widget.categoryId,
                                _notesController.text,
                              );
                              final success = await provider.submitAudit();
                              if (!mounted || !success) return;
                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const ThankYouPage(),
                                ),
                                (route) => route.isFirst,
                              );
                            },
                    ),
                  ),
                ],
              ),
            ),
            if (provider.submitError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  provider.submitError!,
                  style: GoogleFonts.inter(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkNavy, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 48,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Зураг дарах товчийг дарж зургуудаа\nнэмнэ үү',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<String> images, AuditProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (images.isEmpty)
            _buildEmptyState()
          else
            _buildImageGrid(images, provider),
          const SizedBox(height: 16),
          NeoCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Нэмэлт тэмдэглэл',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  onChanged: (value) =>
                      provider.setCategoryNote(widget.categoryId, value),
                  decoration: const InputDecoration(
                    hintText:
                        'Жишээ: үнэ дутуу, facing бага, хөргөгчийн хаалга эвдэрсэн...',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<String> images, AuditProvider provider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: images.length,
      itemBuilder: (context, i) {
        return Stack(
          children: [
            NeoCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                child: Image.file(
                  File(images[i]),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => provider.removeImage(widget.categoryId, i),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.darkNavy, width: 2),
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
