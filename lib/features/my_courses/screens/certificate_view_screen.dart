import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/demo_data.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_toast.dart';
import '../../../widgets/cs_top_bar.dart';

/// Full certificate view [D07].
class CertificateViewScreen extends StatelessWidget {
  const CertificateViewScreen({super.key, required this.certificateId});

  /// The course id the certificate belongs to.
  final String certificateId;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];

  String get _certificateNo {
    final number = certificateId.hashCode.abs() % 9000 + 1000;
    return 'CS-2026-$number';
  }

  String get _dateLabel {
    final now = DateTime.now();
    return '${now.day} ${_monthNames[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final course = DemoData.courseById(certificateId);
    if (course == null) {
      return Scaffold(
        backgroundColor: cs.canvas,
        appBar: const CsTopBar(title: 'Certificate'),
        body: Center(
          child: Text(
            'Certificate not found',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: const CsTopBar(title: 'Certificate'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // --- Ornate certificate card ----------------------------------
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.primary, width: 2),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.border, width: 1),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: CsScheme.proGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.awardBold,
                        size: 36,
                        color: cs.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CodeShikhi',
                      style: AppText.display.copyWith(color: cs.accent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CERTIFICATE OF COMPLETION',
                      style: AppText.caption.copyWith(
                        color: cs.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'This is to certify that',
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DemoData.me.name,
                      style: AppText.h1.copyWith(color: cs.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'has successfully completed',
                      style: AppText.bodySmall.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.title,
                      style: AppText.h2.copyWith(color: cs.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Instructor: ${course.instructor} · '
                      '${course.lessonsCount} lessons · ${course.hours} hours',
                      style: AppText.caption.copyWith(
                        color: cs.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Divider(color: cs.borderHairline, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date issued',
                              style: AppText.caption.copyWith(
                                color: cs.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _dateLabel,
                              style: AppText.label.copyWith(
                                color: cs.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Certificate ID',
                              style: AppText.caption.copyWith(
                                color: cs.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _certificateNo,
                              style: AppText.label.copyWith(
                                color: cs.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CsButton(
              label: 'Share certificate',
              icon: AppIcons.share,
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  text: 'I just completed "${course.title}" on CodeShikhi! '
                      'Certificate $_certificateNo — '
                      'https://codeshikhi.app/course/${course.id}',
                ),
              ),
            ),
            const SizedBox(height: 10),
            CsButton(
              label: 'Download certificate',
              variant: CsButtonVariant.secondary,
              icon: AppIcons.download,
              onPressed: () => showCsToast(
                context,
                'Certificate saved (demo)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
