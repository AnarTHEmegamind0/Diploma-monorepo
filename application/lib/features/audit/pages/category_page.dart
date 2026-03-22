import 'package:core/core/app_theme.dart';
import 'package:core/core/widgets/neo_button.dart';
import 'package:core/core/widgets/neo_card.dart';
import 'package:core/features/audit/models/campaign.dart';
import 'package:core/features/audit/pages/image_page.dart';
import 'package:core/features/audit/providers/audit_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final campaign = provider.selectedCampaign;
    final customer = provider.selectedCustomer;
    final category = provider.currentCategory;
    final categories = campaign?.categories ?? const <CampaignCategory>[];

    if (campaign == null || customer == null || category == null) {
      return const Scaffold(
        body: Center(child: Text('Аудитын мэдээлэл олдсонгүй.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                category.name,
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
                '${campaign.name} • ${customer.name}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProgressStepper(
                total: categories.length,
                current: provider.currentCategoryIndex,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  NeoCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.description ??
                              'Энэ хэсгийн асуултуудад хариулна уу.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...category.questions.map(
                          (question) => Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: _QuestionField(question: question),
                          ),
                        ),
                        if (provider.submitError != null)
                          Text(
                            provider.submitError!,
                            style: GoogleFonts.inter(
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeoCard(
                    padding: const EdgeInsets.all(16),
                    fillColor: const Color(0xFFFFF8E1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            category.hasImage
                                ? 'Энэ хэсэгт зураг шаардлагатай. Доорх товчоор зураг нэмнэ.'
                                : 'Хэрэв шаардлагатай бол энэ хэсгийн нэмэлт зураг оруулж болно.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.darkNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (provider.currentCategoryIndex > 0)
                    Expanded(
                      child: NeoButton(
                        label: 'Өмнөх',
                        backgroundColor: AppColors.white,
                        textColor: AppColors.darkNavy,
                        onPressed: provider.goToPreviousCategory,
                      ),
                    ),
                  if (provider.currentCategoryIndex > 0)
                    const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      label:
                          provider.currentCategoryIndex == categories.length - 1
                          ? 'Зураг оруулах'
                          : 'Дараах хэсэг',
                      backgroundColor: provider.canMoveNext
                          ? AppColors.orange
                          : AppColors.grey.withValues(alpha: 0.4),
                      onPressed: !provider.canMoveNext
                          ? null
                          : () {
                              if (provider.currentCategoryIndex ==
                                  categories.length - 1) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ImagePage(
                                      categoryId: category.id,
                                      categoryName: category.name,
                                    ),
                                  ),
                                );
                                return;
                              }
                              provider.goToNextCategory();
                            },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper({required this.total, required this.current});
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total * 2 - 1, (index) {
        if (index.isOdd) {
          final stepBefore = index ~/ 2;
          return Expanded(
            child: Container(
              height: 3,
              color: stepBefore < current
                  ? AppColors.orange
                  : AppColors.lightGrey,
            ),
          );
        }
        final step = index ~/ 2;
        final isCompleted = step < current;
        final isCurrent = step == current;
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.teal
                : isCurrent
                ? AppColors.orange
                : AppColors.lightGrey,
            border: Border.all(
              color: isCompleted || isCurrent
                  ? AppColors.darkNavy
                  : AppColors.lightGrey,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: AppColors.white)
                : Text(
                    '${step + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isCurrent ? AppColors.white : AppColors.darkNavy,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}

class _QuestionField extends StatelessWidget {
  const _QuestionField({required this.question});

  final CategoryQuestion question;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final currentValue = provider.answerFor(question.id);

    Widget field;
    switch (question.type) {
      case 'yes_no':
        field = Wrap(
          spacing: 10,
          children: ['Тийм', 'Үгүй'].map((option) {
            final selected = currentValue == option;
            return ChoiceChip(
              label: Text(option),
              selected: selected,
              onSelected: (_) => provider.setAnswer(question.id, option),
            );
          }).toList(),
        );
        break;
      case 'number':
        field = TextFormField(
          initialValue: currentValue?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Тоо оруулна уу'),
          onChanged: (value) {
            provider.setAnswer(question.id, int.tryParse(value));
          },
        );
        break;
      case 'text':
        field = TextFormField(
          initialValue: currentValue?.toString() ?? '',
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Хариулт оруулна уу'),
          onChanged: (value) => provider.setAnswer(question.id, value),
        );
        break;
      case 'single_choice':
      case 'dropdown':
        field = DropdownButtonFormField<String>(
          initialValue: currentValue?.toString(),
          decoration: const InputDecoration(hintText: 'Сонголт хийнэ үү'),
          items: question.options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: (value) => provider.setAnswer(question.id, value),
        );
        break;
      case 'multiple_choice':
        final values =
            (currentValue as List?)?.map((item) => item.toString()).toList() ??
            <String>[];
        field = Column(
          children: question.options.map((option) {
            final selected = values.contains(option);
            return CheckboxListTile(
              value: selected,
              title: Text(option),
              contentPadding: EdgeInsets.zero,
              onChanged: (checked) {
                final next = [...values];
                if (checked == true) {
                  next.add(option);
                } else {
                  next.remove(option);
                }
                provider.setAnswer(question.id, next);
              },
            );
          }).toList(),
        );
        break;
      case 'rating':
        final selectedRating = currentValue is int ? currentValue : 0;
        field = Row(
          children: List.generate(5, (index) {
            final rating = index + 1;
            return IconButton(
              onPressed: () => provider.setAnswer(question.id, rating),
              icon: Icon(
                rating <= selectedRating ? Icons.star : Icons.star_border,
                color: AppColors.orange,
              ),
            );
          }),
        );
        break;
      case 'photo':
        field = Text(
          'Энэ асуултын зураг дараагийн алхам дээр нэмэгдэнэ.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey),
        );
        break;
      default:
        field = TextFormField(
          initialValue: currentValue?.toString() ?? '',
          onChanged: (value) => provider.setAnswer(question.id, value),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                question.label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
            ),
            if (question.required)
              Text(
                'Заавал',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
          ],
        ),
        if (question.detectionBased) ...[
          const SizedBox(height: 4),
          Text(
            'YOLO auto-answer дэмжинэ: ${question.productClass ?? '-'}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textGrey),
          ),
        ],
        const SizedBox(height: 10),
        field,
      ],
    );
  }
}
