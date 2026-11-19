import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_toast.dart';

Future<void> showShareSheet(BuildContext context, Course course) =>
    showCsSheet(context, ShareSheet(course: course));

/// Share sheet [C11]: copy link, system share, QR placeholder.
class ShareSheet extends StatelessWidget {
  const ShareSheet({super.key, required this.course});

  final Course course;

  String get _link => 'https://codeshikhi.app/course/${course.id}';

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share this course',
            style: AppText.h2.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            course.title,
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          // QR placeholder (demo — no real QR generation in the demo app).
          Center(
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                color: cs.sunken,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.border, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.grid, size: 48, color: cs.textTertiary),
                  const SizedBox(height: 8),
                  Text(
                    'Scan to open',
                    style: AppText.caption.copyWith(color: cs.textSecondary),
                  ),
                  Text(
                    'QR code (demo)',
                    style: AppText.caption.copyWith(color: cs.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _ShareRow(
            icon: AppIcons.copy,
            title: 'Copy link',
            subtitle: _link,
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: _link));
              if (!context.mounted) return;
              Navigator.of(context).pop();
              showCsToast(context, 'Link copied');
            },
          ),
          const SizedBox(height: 8),
          _ShareRow(
            icon: AppIcons.share,
            title: 'Share via…',
            subtitle: 'Send to WhatsApp, Messenger or any app',
            onTap: () {
              Navigator.of(context).pop();
              SharePlus.instance.share(
                ShareParams(
                  text: 'Check out "${course.title}" on CodeShikhi! $_link',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.borderHairline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.sunken,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: cs.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.label.copyWith(color: cs.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppText.caption.copyWith(
                        color: cs.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                size: 18,
                color: cs.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
