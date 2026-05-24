import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import '../../app/app_theme.dart';
import '../../core/window_preferences.dart';
import '../../features/hosts/controllers/host_controller.dart';
import '../../features/hosts/data/credential_storage.dart';
import '../../features/hosts/models/ssh_host.dart';
import '../../features/hosts/views/host_list_page.dart';
import '../../features/terminal/controllers/terminal_controller.dart';
import '../../features/port_forwarding/controllers/tunnel_controller.dart';
import '../../features/port_forwarding/views/tunnel_page.dart';
import '../../features/settings/controllers/settings_controller.dart';
import '../../features/settings/views/settings_page.dart';
import '../../features/sftp/views/sftp_page.dart';
import '../../features/command_palette/views/command_palette.dart';
import '../../features/hosts/views/host_form_dialog.dart';
import '../../features/terminal/views/credential_prompt_dialog.dart';
import '../../features/terminal/views/terminal_page.dart';
import 'sidebar.dart';
import 'top_bar.dart';

const double _minSidebarWidth = 180.0;
const double _maxSidebarWidth = 360.0;

bool get _isDesktop =>
    Platform.isMacOS || Platform.isLinux || Platform.isWindows;

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener {
  int _selectedIndex = 0;
  bool _sidebarCollapsed = false;
  double _sidebarWidth = sidebarDefaultWidth;
  bool _isFullScreen = false;

  late final HostController _hostController;
  late final TerminalController _terminalController;
  late final SettingsController _settingsController;
  late final TunnelController _tunnelController;
  final _credentials = CredentialStorage();

  @override
  void initState() {
    super.initState();
    if (_isDesktop) windowManager.addListener(this);
    _hostController = HostController()..load();
    _terminalController = TerminalController();
    _settingsController = SettingsController()..load();
    _tunnelController = TunnelController();
    _terminalController.activeSessionIdNotifier.addListener(_updateWindowTitle);
  }

  @override
  void dispose() {
    _terminalController.activeSessionIdNotifier.removeListener(_updateWindowTitle);
    if (_isDesktop) windowManager.removeListener(this);
    _hostController.dispose();
    _terminalController.dispose();
    _settingsController.dispose();
    _tunnelController.dispose();
    super.dispose();
  }

  void _updateWindowTitle() {
    if (!_isDesktop) return;
    final session = _terminalController.activeSession;
    final title = session != null
        ? 'Xell — ${session.host.hostname}'
        : 'Xell';
    windowManager.setTitle(title);
  }

  Future<void> _handleReconnect(String sessionId) async {
    final session = _terminalController.sessions.firstWhere((s) => s.id == sessionId);
    final host = session.host;
    await _terminalController.closeSession(sessionId);
    await _tunnelController.closeForSession(sessionId);
    await _handleConnect(host);
  }

  @override
  void onWindowResized() => WindowPreferences.save();

  @override
  void onWindowMoved() => WindowPreferences.save();

  @override
  void onWindowEnterFullScreen() => setState(() => _isFullScreen = true);

  @override
  void onWindowLeaveFullScreen() => setState(() => _isFullScreen = false);

  void _toggleFullscreen() {
    if (_isDesktop) windowManager.setFullScreen(!_isFullScreen);
  }

  void _closeActiveTab() {
    final id = _terminalController.activeSessionIdNotifier.value;
    if (id != null) _terminalController.closeSession(id);
  }

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  Map<ShortcutActivator, VoidCallback> get _shortcuts {
    if (!_isDesktop) return {};
    final mac = Platform.isMacOS;
    return {
      SingleActivator(LogicalKeyboardKey.keyK, meta: mac, control: !mac):
          _showCommandPalette,
      if (mac)
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
          meta: true,
        ): _toggleFullscreen
      else
        const SingleActivator(LogicalKeyboardKey.f11): _toggleFullscreen,
      SingleActivator(LogicalKeyboardKey.keyW, meta: mac, control: !mac):
          _closeActiveTab,
      SingleActivator(LogicalKeyboardKey.digit1, meta: mac, control: !mac):
          () => _selectTab(0),
      SingleActivator(LogicalKeyboardKey.digit2, meta: mac, control: !mac):
          () => _selectTab(1),
      SingleActivator(LogicalKeyboardKey.digit3, meta: mac, control: !mac):
          () => _selectTab(2),
      SingleActivator(LogicalKeyboardKey.digit4, meta: mac, control: !mac):
          () => _selectTab(3),
    };
  }

  void _showCommandPalette() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, _) => CommandPalette(
        hosts: _hostController.hostsNotifier.value,
        onConnect: _handleConnect,
        onOpenSettings: () => setState(() => _selectedIndex = 4),
        onCreateHost: () {
          setState(() => _selectedIndex = 0);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog<void>(
              context: context,
              builder: (_) => HostFormDialog(controller: _hostController),
            );
          });
        },
      ),
    );
  }

  void _onSidebarResize(double delta) {
    setState(() {
      _sidebarWidth = (_sidebarWidth + delta).clamp(
        _minSidebarWidth,
        _maxSidebarWidth,
      );
    });
  }

  double get _effectiveSidebarWidth =>
      _sidebarCollapsed ? sidebarCollapsedWidth : _sidebarWidth;

  // ── Connect flow ─────────────────────────────────────────────────────────

  Future<void> _handleConnect(SshHost host) async {
    if (host.authType == AuthType.sshAgent) {
      _showSnackbar('SSH Agent auth is not yet supported.');
      return;
    }

    final stored = host.authType == AuthType.password
        ? await _credentials.loadPassword(host.id)
        : await _credentials.loadPassphrase(host.id);

    String? credential = stored;
    if (credential == null) {
      if (!mounted) return;
      credential = await showDialog<String>(
        context: context,
        builder: (_) => CredentialPromptDialog(
          host: host,
          isPassphrase: host.authType == AuthType.privateKey,
        ),
      );
      if (credential == null) return;
    }

    if (mounted) setState(() => _selectedIndex = 1);

    try {
      await _terminalController.createSession(
        host: host,
        password: host.authType == AuthType.password ? credential : null,
        passphrase: host.authType == AuthType.privateKey ? credential : null,
      );
    } catch (_) {
      return;
    }

    await _hostController.markConnected(host.id);

    try {
      if (host.authType == AuthType.password) {
        await _credentials.savePassword(host.id, credential);
      } else if (host.authType == AuthType.privateKey) {
        await _credentials.savePassphrase(host.id, credential);
      }
    } catch (_) {}
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.text, fontSize: 13),
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  Widget _pageContent(int index) => switch (index) {
    0 => HostListPage(controller: _hostController, onConnect: _handleConnect),
    1 => ValueListenableBuilder<double>(
      valueListenable: _settingsController.fontSizeNotifier,
      builder: (context, fontSize, child) => TerminalPage(
        controller: _terminalController,
        fontSize: fontSize,
        onCloseSession: (id) async {
          await _terminalController.closeSession(id);
          await _tunnelController.closeForSession(id);
        },
        onReconnect: _handleReconnect,
      ),
    ),
    2 => SftpPage(terminalController: _terminalController),
    3 => TunnelPage(
      controller: _tunnelController,
      terminalController: _terminalController,
    ),
    4 => SettingsPage(controller: _settingsController),
    _ => const _PlaceholderPage(),
  };

  Widget _animatedPage(int index) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 180),
    switchInCurve: Curves.easeOut,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animation) =>
        FadeTransition(opacity: animation, child: child),
    child: KeyedSubtree(
      key: ValueKey(index),
      child: _pageContent(index),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: _shortcuts,
      child: Focus(
        autofocus: true,
        child: _isDesktop ? _buildDesktop() : _buildMobile(),
      ),
    );
  }

  Widget _buildDesktop() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            width: _effectiveSidebarWidth,
            child: Sidebar(
              selectedIndex: _selectedIndex,
              isCollapsed: _sidebarCollapsed,
              onItemSelected: (i) => setState(() => _selectedIndex = i),
              onSettingsTap: () => setState(() => _selectedIndex = 4),
              onToggleCollapse: () =>
                  setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
          ),
          if (!_sidebarCollapsed) _ResizeHandle(onDrag: _onSidebarResize),
          Expanded(
            child: Column(
              children: [
                ValueListenableBuilder<String?>(
                  valueListenable: _terminalController.activeSessionIdNotifier,
                  builder: (context, sessionId, child) => TopBar(
                    onCommandPaletteTap: _showCommandPalette,
                    onSettingsTap: () => setState(() => _selectedIndex = 4),
                    isFullScreen: _isFullScreen,
                    onToggleFullscreen: _toggleFullscreen,
                    activeSession:
                        _terminalController.activeSession?.host.hostname,
                  ),
                ),
                Expanded(child: _animatedPage(_selectedIndex)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile() {
    // Settings lives at index 4 but the bottom nav only has 4 items (0-3).
    // We handle tapping the settings icon via a dedicated nav item at index 4.
    final navIndex = _selectedIndex.clamp(0, 4);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _animatedPage(_selectedIndex)),
      bottomNavigationBar: _MobileNavBar(
        selectedIndex: navIndex,
        onItemSelected: (i) => setState(() => _selectedIndex = i),
        onCommandPaletteTap: _showCommandPalette,
      ),
    );
  }
}

// ── Mobile bottom nav bar ─────────────────────────────────────────────────────

class _MobileNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onCommandPaletteTap;

  const _MobileNavBar({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onCommandPaletteTap,
  });

  static const _items = [
    (icon: Icons.dns_outlined, label: 'Hosts'),
    (icon: Icons.terminal_outlined, label: 'Terminal'),
    (icon: Icons.folder_open_outlined, label: 'SFTP'),
    (icon: Icons.alt_route_outlined, label: 'Tunnels'),
    (icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            ..._items.indexed.map((e) {
              final idx = e.$1;
              final item = e.$2;
              final selected = selectedIndex == idx;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onItemSelected(idx),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: selected
                              ? AppColors.accent
                              : AppColors.textMuted,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? AppColors.accent
                                : AppColors.textMuted,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Desktop-only widgets ──────────────────────────────────────────────────────

class _ResizeHandle extends StatefulWidget {
  final ValueChanged<double> onDrag;
  const _ResizeHandle({required this.onDrag});

  @override
  State<_ResizeHandle> createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<_ResizeHandle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onHorizontalDragUpdate: (d) => widget.onDrag(d.delta.dx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 4,
          color: _hovered
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Coming soon.',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),
    );
  }
}
