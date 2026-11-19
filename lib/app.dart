import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalCupertinoLocalizations, GlobalMaterialLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/screens/startup_error_screen.dart';
import 'navigation/app_router.dart';
import 'providers/app_providers.dart';
import 'providers/startup_provider.dart';
import 'theme/app_theme.dart';

/// Root widget. Gates on the startup result first: when local storage
/// could not be started, the error screen (with Retry) shows instead of
/// the router app, whose providers need the Hive boxes. Otherwise the
/// normal app runs — theme + locale come from [settingsProvider]; when
/// the locale is Bangla the theme switches its font family to AnekBangla.
class CodeShikhiApp extends ConsumerWidget {
  const CodeShikhiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(startupProvider);
    if (!startup.storageReady) {
      return MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: StartupErrorScreen(
          error: startup.storageError ?? 'Unknown storage error',
          onRetry: () => ref.read(startupProvider.notifier).retry(),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    return const _RouterApp();
  }
}

/// The normal app (router + settings-driven theme/locale). Split out so
/// [settingsProvider] — which reads Hive — is never watched while
/// storage is down.
class _RouterApp extends ConsumerWidget {
  const _RouterApp();

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
