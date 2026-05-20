import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';
import '../../../app/app_theme.dart';
import '../models/terminal_session.dart';

const _terminalTheme = TerminalTheme(
  cursor: Color(0xFFE6EAF2),
  selection: Color(0x445E81F4),
  foreground: Color(0xFFE6EAF2),
  background: Color(0xFF0F1115),
  black: Color(0xFF1E1E2E),
  red: Color(0xFFF38BA8),
  green: Color(0xFFA6E3A1),
  yellow: Color(0xFFF9E2AF),
  blue: Color(0xFF89B4FA),
  magenta: Color(0xFFCBA6F7),
  cyan: Color(0xFF89DCEB),
  white: Color(0xFFBAC2DE),
  brightBlack: Color(0xFF585B70),
  brightRed: Color(0xFFF38BA8),
  brightGreen: Color(0xFFA6E3A1),
  brightYellow: Color(0xFFF9E2AF),
  brightBlue: Color(0xFF89B4FA),
  brightMagenta: Color(0xFFCBA6F7),
  brightCyan: Color(0xFF89DCEB),
  brightWhite: Color(0xFFE6EAF2),
  searchHitBackground: Color(0xFFCBA6F7),
  searchHitBackgroundCurrent: Color(0xFFF9E2AF),
  searchHitForeground: Color(0xFF1E1E2E),
);

class TerminalWidget extends StatelessWidget {
  final TerminalSession session;
  final double fontSize;

  const TerminalWidget({
    super.key,
    required this.session,
    this.fontSize = 13.5,
  });

  @override
  Widget build(BuildContext context) {
    return switch (session.status) {
      SessionStatus.connecting => _ConnectingView(host: session.host.hostname),
      SessionStatus.connected => _ConnectedView(session: session, fontSize: fontSize),
      SessionStatus.disconnected => _EndedView(host: session.host.hostname),
      SessionStatus.error => _ErrorView(message: session.errorMessage ?? 'Unknown error'),
    };
  }
}

class _ConnectedView extends StatelessWidget {
  final TerminalSession session;
  final double fontSize;
  const _ConnectedView({required this.session, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return TerminalView(
      session.xterm!,
      theme: _terminalTheme,
      textStyle: TerminalStyle(fontSize: fontSize, fontFamily: 'monospace'),
      autofocus: true,
      padding: const EdgeInsets.all(AppSpacing.s8),
    );
  }
}

class _ConnectingView extends StatelessWidget {
  final String host;
  const _ConnectingView({required this.host});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Connecting to $host...',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 32,
            color: Color(0xFFF87171),
          ),
          const SizedBox(height: AppSpacing.s16),
          const Text(
            'Connection failed',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EndedView extends StatelessWidget {
  final String host;
  const _EndedView({required this.host});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.terminal_outlined,
            size: 32,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Session ended — $host',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
