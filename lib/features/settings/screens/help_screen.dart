import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../i18n/app_strings.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/cs_text_field.dart';
import '../../../widgets/cs_top_bar.dart';
import '../widgets/help_articles.dart';
import '../widgets/settings_row.dart';

/// Help center [K15]: searchable article list + contact support row.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final query = _query.trim().toLowerCase();
    final visible = query.isEmpty
        ? helpArticles
        : helpArticles
            .where(
              (a) =>
                  a.title.toLowerCase().contains(query) ||
                  a.paragraphs.any((p) => p.toLowerCase().contains(query)),
            )
            .toList();
    return Scaffold(
      backgroundColor: cs.canvas,
      appBar: CsTopBar(title: 'Help center'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          CsTextField(
            hint: 'Search help articles…',
            controller: _searchController,
            prefixIcon: AppIcons.search,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 20),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Center(
                child: Text(
                  context.tr('noResults'),
                  style: AppText.body.copyWith(color: cs.textSecondary),
                ),
              ),
            )
          else
            CsSettingsSection(
              title: 'Articles',
              children: [
                for (final article in visible)
                  CsSettingsRow(
                    icon: AppIcons.documentText,
                    title: article.title,
                    onTap: () =>
                        context.push('/settings/help/${article.id}'),
                  ),
              ],
            ),
          const SizedBox(height: 24),
          CsSettingsSection(
            title: 'Still stuck?',
            children: [
              CsSettingsRow(
                icon: AppIcons.message,
                title: context.tr('contactSupport'),
                subtitle: 'We usually reply within 24 hours',
                onTap: () => context.push('/settings/support'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
