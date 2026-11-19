import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo_data.dart';
import '../../../data/models.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';
import '../../../widgets/cs_empty_state.dart';
import '../../../widgets/cs_top_bar.dart';
import '../player_helpers.dart';

/// Module complete celebration [E19].
class ModuleCompleteScreen extends ConsumerWidget {
  const ModuleCompleteScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  final String courseId;
  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = DemoData.courseById(courseId);
    Module? module;
    if (course != null) {
      for (final m in course.modules) {
        if (m.id == moduleId) module = m;
      }
    }
    if (course == null || module == null) {
      return Scaffold(
        appBar: const CsTopBar(title: 'Module complete'),
        body: CsEmptyState(
          icon: AppIcons.book,
          title: 'Module not found',
          body: 'This module does not exist in the demo catalog.',
          actionLabel: 'Back to Home',
          onAction: () => context.go('/home'),
        ),
      );
    }
    final cs = context.cs;
    final moduleIndex =
        course.modules.indexWhere((m) => m.id == moduleId);
    final isLastModule = moduleIndex + 1 >= course.modules.length;
    final xpEarned = module.lessons.length * 20;

    void goNext() {
      if (isLastModule) {
        context.push('/course-complete?courseId=${course.id}');
        return;
      }
      final nextModule = course.modules[moduleIndex + 1];
      if (nextModule.lessons.isEmpty) {
        context.push('/course-complete?courseId=${course.id}');
        return;
      }
      context.push(
        lessonRoute(nextModule.lessons.first, course.id),
      );
    }

    return Scaffold(
      appBar: const CsTopBar(title: '', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: cs.sunken,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.medalStarBold,
                  size: 48,
                  color: cs.accent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Module complete!',
              style: AppText.h1.copyWith(color: cs.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '“${module.title}” · ${course.title}',
              style: AppText.body.copyWith(color: cs.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.raised,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.borderHairline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ModuleStat(
                    value: '${module.lessons.length}',
                    label: 'Lessons done',
                  ),
                  _ModuleStat(
                    value: '+$xpEarned XP',
                    label: 'Earned in module',
                  ),
                  _ModuleStat(
                    value: '${moduleIndex + 1}/${course.modules.length}',
                    label: 'Modules',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CsButton(
              label: isLastModule ? 'Finish course' : 'Next module',
              icon: AppIcons.arrowRightBold,
              onPressed: goNext,
            ),
            const SizedBox(height: 12),
            CsButton(
              label: 'Back to course',
              variant: CsButtonVariant.secondary,
              onPressed: () => context.push('/course/${course.id}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleStat extends StatelessWidget {
  const _ModuleStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Column(
      children: [
        Text(
          value,
          style: AppText.h3.copyWith(color: cs.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppText.caption.copyWith(color: cs.textSecondary),
        ),
      ],
    );
  }
}
