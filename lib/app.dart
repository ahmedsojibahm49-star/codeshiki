import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalCupertinoLocalizations, GlobalMaterialLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation/app_router.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';

/// Root widget. Theme + locale come from [settingsProvider]; when the
/// locale is Bangla the theme switches its font family to AnekBangla.
class CodeShikhiApp extends ConsumerWidget {
  const CodeShikhiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final bangla = settings.locale.languageCode == 'bn';

    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.light(bangla: bangla),
      darkTheme: AppTheme.dark(bangla: bangla),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: const [Locale('en'), Locale('bn')],
      localizationsDelegates: const [
        // GlobalMaterialLocalizations comes from package:material_ui
        // (the flutter_localizations one is deprecated in Flutter 3.50).
        // No Cupertino delegate: the app has no Cupertino widgets.
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
