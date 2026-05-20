import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../shared/layouts/app_shell.dart';

class ShellbrickApp extends StatelessWidget {
  const ShellbrickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shellbrick',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const AppShell(),
    );
  }
}
