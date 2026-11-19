import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/hive_boxes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_button.dart';

class _IntroPage {
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

const _pages = [
  _IntroPage(
    icon: AppIcons.book,
    title: 'Learn coding in Bangla',
    body:
        'Full courses in Bangla — from your very first line of code to real, '
        'job-ready projects.',
  ),
  _IntroPage(
    icon: AppIcons.code,
    title: 'Practice with real code',
    body:
        'Write, run and debug code right inside the app with the built-in '
        'code editor.',
  ),
  _IntroPage(
    icon: AppIcons.trophy,
    title: 'Earn XP, streaks & certificates',
    body:
        'Stay consistent, climb the leaderboard and earn certificates you can '
        'share.',
  ),
];

/// Intro carousel [A02-A04]. 3 pages, dots, Skip -> /welcome.
/// "Get started" on the last page marks the intro seen, then -> /welcome.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _skip() => context.go('/welcome');

  Future<void> _getStarted() async {
    await HiveBoxes.settings.put('seenIntro', true);
    if (!mounted) return;
    context.go('/welcome');
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _getStarted();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: cs.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 8),
                child: CsButton(
                  label: 'Skip',
                  variant: CsButtonVariant.ghost,
                  size: CsButtonSize.s,
                  fullWidth: false,
                  onPressed: _skip,
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, size: 64, color: cs.accent),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: AppText.h1.copyWith(color: cs.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: AppText.body.copyWith(color: cs.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final active = index == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? cs.primary : cs.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: CsButton(
                label: isLast ? 'Get started' : 'Next',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
