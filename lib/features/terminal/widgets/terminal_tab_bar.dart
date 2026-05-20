import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../models/terminal_session.dart';

class TerminalTabBar extends StatelessWidget {
  final List<TerminalSession> sessions;
  final String? activeSessionId;
  final ValueChanged<String> onSelectSession;
  final ValueChanged<String> onCloseSession;

  const TerminalTabBar({
    super.key,
    required this.sessions,
    required this.activeSessionId,
    required this.onSelectSession,
    required this.onCloseSession,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: sessions
            .map(
              (s) => _Tab(
                session: s,
                isActive: s.id == activeSessionId,
                onTap: () => onSelectSession(s.id),
                onClose: () => onCloseSession(s.id),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  final TerminalSession session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _Tab({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _hovered = false;

  Color get _statusColor => switch (widget.session.status) {
    SessionStatus.connecting => AppColors.textMuted.withValues(alpha: 0.5),
    SessionStatus.connected => const Color(0xFF4ADE80),
    SessionStatus.disconnected => AppColors.textMuted.withValues(alpha: 0.3),
    SessionStatus.error => const Color(0xFFF87171),
  };

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.background
                : _hovered
                ? AppColors.border.withValues(alpha: 0.3)
                : Colors.transparent,
            border: widget.isActive
                ? const Border(
                    top: BorderSide(color: AppColors.accent, width: 2),
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                widget.session.host.name,
                style: TextStyle(
                  color: widget.isActive
                      ? AppColors.text
                      : AppColors.textMuted,
                  fontSize: 12.5,
                  fontWeight: widget.isActive
                      ? FontWeight.w500
                      : FontWeight.w400,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              GestureDetector(
                onTap: widget.onClose,
                behavior: HitTestBehavior.opaque,
                child: AnimatedOpacity(
                  opacity: _hovered || widget.isActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 120),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
