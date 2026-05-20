import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../models/ssh_host.dart';

class HostRow extends StatefulWidget {
  final SshHost host;
  final bool isKeyboardFocused;
  final VoidCallback onConnect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const HostRow({
    super.key,
    required this.host,
    required this.onConnect,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
    this.isKeyboardFocused = false,
  });

  @override
  State<HostRow> createState() => _HostRowState();
}

class _HostRowState extends State<HostRow> {
  bool _hovered = false;

  SshHost get host => widget.host;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onConnect,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s8,
            vertical: 1,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s12,
          ),
          decoration: BoxDecoration(
            color: widget.isKeyboardFocused
                ? AppColors.accent.withValues(alpha: 0.08)
                : _hovered
                ? AppColors.surface.withValues(alpha: 0.8)
                : Colors.transparent,
            border: widget.isKeyboardFocused
                ? Border.all(color: AppColors.accent.withValues(alpha: 0.3))
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _StatusDot(connected: false),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          host.name,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Text(
                          '${host.username}@${host.hostname}:${host.port}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (host.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: host.tags
                            .map((t) => _TagChip(label: t))
                            .toList(),
                      ),
                    ],
                    if (host.lastConnectedAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatAge(host.lastConnectedAt!),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: _hovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 120),
                child: Row(
                  children: [
                    _RowIconButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit',
                      onTap: widget.onEdit,
                    ),
                    const SizedBox(width: 2),
                    _RowIconButton(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete',
                      onTap: widget.onDelete,
                      danger: true,
                    ),
                    const SizedBox(width: AppSpacing.s8),
                  ],
                ),
              ),
              _FavoriteButton(
                isFavorite: host.isFavorite,
                onTap: widget.onToggleFavorite,
              ),
              const SizedBox(width: AppSpacing.s8),
              AnimatedOpacity(
                opacity: _hovered ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 120),
                child: _ConnectButton(onTap: widget.onConnect),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAge(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return 'Long ago';
  }
}

class _StatusDot extends StatelessWidget {
  final bool connected;
  const _StatusDot({required this.connected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: connected
            ? const Color(0xFF4ADE80)
            : AppColors.textMuted.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10.5,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          size: 15,
          color: isFavorite
              ? AppColors.accent
              : AppColors.textMuted.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ConnectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.arrow_forward,
          size: 14,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _RowIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool danger;

  const _RowIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.danger = false,
  });

  @override
  State<_RowIconButton> createState() => _RowIconButtonState();
}

class _RowIconButtonState extends State<_RowIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _hovered
                  ? (widget.danger
                        ? const Color(0xFFF87171).withValues(alpha: 0.12)
                        : AppColors.border.withValues(alpha: 0.8))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 14,
              color: _hovered && widget.danger
                  ? const Color(0xFFF87171)
                  : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
