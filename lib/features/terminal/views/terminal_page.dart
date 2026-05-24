import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../controllers/terminal_controller.dart';
import '../widgets/terminal_tab_bar.dart';
import '../widgets/terminal_widget.dart';

class TerminalPage extends StatelessWidget {
  final TerminalController controller;
  final double fontSize;
  final Future<void> Function(String id)? onCloseSession;
  final Future<void> Function(String sessionId)? onReconnect;

  const TerminalPage({
    super.key,
    required this.controller,
    this.fontSize = 13.5,
    this.onCloseSession,
    this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.sessionsNotifier,
      builder: (context, sessions, _) {
        if (sessions.isEmpty) return const _EmptyTerminalState();

        return ValueListenableBuilder<String?>(
          valueListenable: controller.activeSessionIdNotifier,
          builder: (context, activeId, _) {
            final active = controller.activeSession;

            return Column(
              children: [
                TerminalTabBar(
                  sessions: sessions,
                  activeSessionId: activeId,
                  onSelectSession: controller.setActiveSession,
                  onCloseSession: (id) =>
                      onCloseSession != null
                          ? onCloseSession!(id)
                          : controller.closeSession(id),
                ),
                Expanded(
                  child: active == null
                      ? const _EmptyTerminalState()
                      : TerminalWidget(
                          key: ValueKey(active.id),
                          session: active,
                          fontSize: fontSize,
                          onReconnect: onReconnect == null
                              ? null
                              : () => onReconnect!(active.id),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _EmptyTerminalState extends StatelessWidget {
  const _EmptyTerminalState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.terminal_outlined,
            size: 40,
            color: AppColors.textMuted.withValues(alpha: 0.25),
          ),
          const SizedBox(height: AppSpacing.s16),
          const Text(
            'No active sessions',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          const Text(
            'Connect to a host from the Hosts tab.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
