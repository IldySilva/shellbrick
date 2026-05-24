import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../features/settings/controllers/settings_controller.dart';
import '../shared/layouts/app_shell.dart';

class ShellbrickApp extends StatelessWidget {
  const ShellbrickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) => MaterialApp(
        title: 'Shellbrick',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        home: const AppShell(),
      ),
    );
  }
}
