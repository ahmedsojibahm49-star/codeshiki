import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_sheet.dart';
import '../../../widgets/cs_toast.dart';

/// Share sheet [F16]: copy the project's public link, share it via the
/// platform share sheet, or open its public project page.
Future<void> showShareSheet(BuildContext context, CodeProject project) {
  final link = 'https://codeshikhi.app/code/${project.id}';
  final cs = context.cs;
  return showCsSheet<void>(
    context,
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share project',
            style: AppText.h3.copyWith(color: cs.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            project.title,
            style: AppText.bodySmall.copyWith(color: cs.textSecondary),
          ),
          const SizedBox(height: 16),
          _ShareRow(
            icon: AppIcons.link,
            title: 'Copy link',
            subtitle: link,
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: link));
              if (!context.mounted) return;
              Navigator.of(context).pop();
              showCsToast(context, 'Link copied to clipboard');
            },
          ),
          _ShareRow(
            icon: AppIcons.share,
            title: 'Share via…',
            subtitle: 'Send the link with any app',
            onTap: () async {
              Navigator.of(context).pop();
              await SharePlus.instance.share(
                ShareParams(
                  text:
                      'Check out my CodeShikhi project "${project.title}" — $link',
                  subject: project.title,
                ),
              );
            },
          ),
          _ShareRow(
            icon: AppIcons.eye,
            title: 'Open public page',
            subtitle: 'See how others view this project',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/code/project/${project.id}');
            },
          ),
        ],
      ),
    ),
  );
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.sunken,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: cs.accent),
      ),
      title: Text(
        title,
        style: AppText.label.copyWith(color: cs.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: AppText.bodySmall.copyWith(color: cs.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        AppIcons.chevronRight,
        size: 20,
        color: cs.textTertiary,
      ),
      onTap: onTap,
    );
  }
}
