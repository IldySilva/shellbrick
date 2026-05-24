# CLAUDE.md

# Shellbrick — Claude Code Project Guide

## 1. Project Identity

Shellbrick is an open-source SSH workspace built with Flutter and Dart.

It is a minimalist, native-feeling alternative to tools like Termius, focused on:

- SSH host management
- Integrated terminal sessions
- Local-first storage
- Secure credentials
- Fast keyboard workflows
- macOS, Linux, iOS, and Android platform experience

Shellbrick starts as a focused SSH workspace and grows into a full DevOps toolkit — Docker, Kubernetes, and AI-assisted workflows are explicitly on the post-MVP roadmap.

The MVP priority is: SSH workspace done right. Then build outward from there.

---

## 2. Product Vision

Shellbrick should feel like:

> A calm, modern DevOps workspace built for serious developers who value focus, speed, trust, and native platform quality — on every device. Starting with SSH, growing into Docker, Kubernetes, and AI-assisted workflows.

The product should be:

- minimal
- fast
- elegant
- trustworthy
- keyboard-friendly
- terminal-first
- local-first
- open-source-first

---

## 3. MVP Scope

The MVP focuses only on:

- Flutter desktop + mobile app shell
- Host management
- SSH connection
- Integrated terminal
- Secure credential storage
- Local settings
- Command palette
- Basic SFTP
- Basic local port forwarding

Mobile-specific MVP constraints:
- `window_manager` is desktop-only — never initialize it on iOS/Android; use `Platform.isMacOS || Platform.isLinux || Platform.isWindows` guards (`Platform.isDesktop` does not exist in `dart:io`)
- Sidebar layout is desktop-only — mobile uses a bottom navigation bar
- Keyboard shortcuts (`⌘K`, `⌘W`, etc.) only register on desktop — skip registration on mobile
- Background SSH sessions are not supported on iOS in MVP (foreground only)

Do not build in MVP (post-MVP roadmap items, not permanent exclusions):

- AI-assisted terminal workflows → post-MVP
- Docker container management → post-MVP
- Kubernetes cluster access → post-MVP
- Plugin / extension system → post-MVP

Do not build at all (not on the roadmap):

- cloud sync
- user accounts
- collaboration / teams
- complex database abstraction
- advanced dependency injection
- over-engineered architecture

---

## 4. Technology Stack

Use:

- Flutter (Desktop + Mobile)
- Dart
- macOS support
- Linux support
- iOS support
- Android support

Post-MVP:

- Windows support

Core packages:

```yaml
dependencies:
  flutter:
    sdk: flutter

  dartssh2:
  xterm:
  shared_preferences:
  flutter_secure_storage:
  file_picker:
  window_manager:
```

Use these packages only when needed.

---

## 5. Architecture Philosophy

Keep the architecture simple.

Use:

- feature-first folder structure
- plain Dart classes
- small controllers
- simple services
- `setState`
- `ValueNotifier`
- `ValueListenableBuilder`

Avoid:

- Bloc
- Riverpod
- Provider
- GetX
- Redux
- Clean Architecture over-abstraction
- repository/service explosion
- premature dependency injection
- unnecessary abstractions

The MVP rule:

> Make it work. Make it simple. Make it beautiful. Do not over-engineer.

---

## 6. State Management Rules

Use `setState` for local widget state:

- form fields
- loading flags
- hover state
- modal visibility
- temporary UI state

Use `ValueNotifier` for shared feature state:

- hosts list
- active terminal session
- connection status
- settings
- recent hosts
- favorites

Use `ValueListenableBuilder` to rebuild UI from notifiers.

Example:

```dart
final hostsNotifier = ValueNotifier<List<SshHost>>([]);
```

Do not introduce external state management packages.

---

## 7. Folder Structure

Use this structure unless there is a strong reason not to:

```txt
lib/
│
├── main.dart
│
├── app/
│   ├── shellbrick_app.dart
│   ├── app_theme.dart
│   └── app_routes.dart
│
├── core/
│   ├── constants.dart
│   ├── exceptions.dart
│   ├── result.dart
│   ├── utils.dart
│   └── extensions.dart
│
├── features/
│
│   ├── hosts/
│   │   ├── models/
│   │   │   └── ssh_host.dart
│   │   ├── data/
│   │   │   └── host_local_storage.dart
│   │   ├── controllers/
│   │   │   └── host_controller.dart
│   │   ├── views/
│   │   │   ├── host_list_page.dart
│   │   │   └── host_form_page.dart
│   │   └── widgets/
│
│   ├── terminal/
│   │   ├── models/
│   │   │   └── terminal_session.dart
│   │   ├── services/
│   │   │   └── ssh_service.dart
│   │   ├── controllers/
│   │   │   └── terminal_controller.dart
│   │   ├── views/
│   │   │   └── terminal_page.dart
│   │   └── widgets/
│
│   ├── command_palette/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── views/
│   │   └── widgets/
│
│   ├── sftp/
│   │   ├── services/
│   │   ├── models/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── widgets/
│
│   ├── port_forwarding/
│   │   ├── services/
│   │   ├── models/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── widgets/
│
│   └── settings/
│       ├── data/
│       │   └── settings_storage.dart
│       ├── controllers/
│       │   └── settings_controller.dart
│       ├── views/
│       │   └── settings_page.dart
│       └── widgets/
│
└── shared/
    ├── widgets/
    ├── layouts/
    └── themes/
```

---

## 8. Data Models

### SSH Host

```dart
class SshHost {
  final String id;
  final String name;
  final String hostname;
  final int port;
  final String username;
  final AuthType authType;
  final String? privateKeyPath;
  final List<String> tags;
  final bool isFavorite;
  final DateTime? lastConnectedAt;

  const SshHost({
    required this.id,
    required this.name,
    required this.hostname,
    required this.port,
    required this.username,
    required this.authType,
    this.privateKeyPath,
    this.tags = const [],
    this.isFavorite = false,
    this.lastConnectedAt,
  });
}
```

### Auth Type

```dart
enum AuthType {
  password,
  privateKey,
  sshAgent,
}
```

Models should include:

- `toJson`
- `fromJson`
- `copyWith`
- validation helpers when useful

Avoid code generation for MVP.

---

## 9. Local Storage Strategy

Use `shared_preferences` for non-sensitive data.

Store:

```txt
shellbrick.hosts
shellbrick.themeMode
shellbrick.recentHosts
shellbrick.windowPreferences
shellbrick.terminalFontSize
shellbrick.accentColor
```

Hosts are stored as JSON strings.

Example:

```json
[
  {
    "id": "host_001",
    "name": "Production VPS",
    "hostname": "192.168.1.10",
    "port": 22,
    "username": "root",
    "authType": "privateKey",
    "privateKeyPath": "/Users/me/.ssh/id_rsa",
    "tags": ["production"],
    "isFavorite": true
  }
]
```

Do not use SQLite, Drift, Isar, Hive, or ObjectBox in the MVP.

---

## 10. Secure Storage Strategy

Use `flutter_secure_storage` for sensitive data.

Store:

```txt
shellbrick.host.{hostId}.password
shellbrick.host.{hostId}.privateKeyPassphrase
```

Security rules:

- never store passwords in SharedPreferences
- never store private key contents in SharedPreferences
- never log credentials
- never print secrets
- never send credentials anywhere
- private keys stay local
- no telemetry by default
- no cloud dependency in MVP

For private keys, MVP should store only the file path.

---

## 11. Main Services

### HostLocalStorage

Responsibilities:

- load hosts
- save hosts
- update host
- delete host
- persist recent hosts
- persist favorites

### SshService

Responsibilities:

- establish SSH connection
- authenticate with password
- authenticate with private key
- create shell session
- handle input stream
- handle output stream
- disconnect session
- handle SSH errors

### TerminalController

Responsibilities:

- create terminal session
- bind SSH output to xterm
- bind terminal input to SSH shell
- handle terminal resizing
- close session safely
- expose session status through `ValueNotifier`

### SettingsStorage

Responsibilities:

- save theme mode
- save terminal font size
- save accent color
- save window preferences

---

## 12. Core User Flow

```txt
User opens Shellbrick
  ↓
App loads hosts from SharedPreferences
  ↓
User selects a host
  ↓
App retrieves credentials from secure storage
  ↓
SshService opens SSH connection using dartssh2
  ↓
TerminalPage opens xterm.dart
  ↓
SSH output streams into terminal
  ↓
User input streams into remote shell
  ↓
User closes session
  ↓
Shellbrick disposes connection safely
```

---

## 13. UI/UX Philosophy

Shellbrick should look and feel:

- minimalist
- dark-first
- typography-driven
- calm
- serious
- professional
- native
- spacious
- low-noise

Avoid:

- clutter
- dashboard-heavy SaaS UI
- excessive borders
- excessive shadows
- unnecessary gradients
- cyberpunk visuals
- toy-like terminal aesthetics

Inspired by:

- Linear
- Raycast
- Ghostty
- Warp
- VS Code

---

## 14. Design System Rules

### Theme

Dark-first.

Light mode may be added later.

Recommended palette style:

```txt
Background: #0F1115
Surface:    #151922
Border:     #232734
Text:       #E6EAF2
Muted Text: #9AA4B2
```

### Accent Colors

Use only one accent color at a time.

Accent color is for:

- active states
- selected items
- focus states
- primary actions

Do not overuse accent colors.

### Typography

UI font:

- Inter
- SF Pro on macOS if appropriate

Terminal font:

- JetBrains Mono
- Geist Mono
- Fira Code

### Spacing

Use consistent spacing:

```txt
4, 8, 12, 16, 24, 32, 48, 64
```

Whitespace is part of the design.

### Animations

Use subtle animations only:

- fade
- slide
- scale

Recommended duration:

```txt
120ms, 180ms, 240ms
```

Avoid flashy, bouncy, distracting animations.

---

## 15. Main Screens

### Host List Page

Must include:

- host list
- search
- favorites
- recent hosts
- tags
- connect button
- edit/delete actions

### Host Form Page

Must include:

- host name
- hostname/IP
- port
- username
- authentication type
- password input
- private key picker
- tags
- notes

### Terminal Page

Must include:

- terminal emulator
- connection status
- session title
- reconnect action
- close session action

Terminal must be the visual focus.

### Settings Page

Must include:

- theme mode
- terminal font size
- accent color
- clear local data
- app information

### Command Palette

Must include:

- search input
- host search
- connect action
- open settings action
- create host action
- recent host actions

Default shortcuts:

```txt
macOS: CMD + K
Linux: CTRL + K
ESC: Close
```

---

## 16. MVP TODO Priority

Build in this order:

### Phase 1 — Foundation

- Flutter desktop setup
- dark theme
- app shell
- sidebar layout
- window management

### Phase 2 — Host Management

- `SshHost` model
- SharedPreferences storage
- host list
- host form
- create/edit/delete hosts

### Phase 3 — Secure Credentials

- `flutter_secure_storage`
- password storage
- private key path support
- file picker integration

### Phase 4 — SSH Connectivity

- `dartssh2`
- password authentication
- private key authentication
- basic connection errors

### Phase 5 — Terminal

- `xterm.dart`
- pipe SSH output to terminal
- pipe terminal input to SSH
- close/dispose session

### Phase 6 — UX Polish

- search
- favorites
- recent hosts
- keyboard shortcuts
- command palette

### Phase 7 — Advanced MVP Features

- SFTP browser
- local port forwarding

---

## 17. Testing Expectations

Add tests where useful, but do not block MVP speed with excessive test infrastructure.

Prioritize tests for:

- `SshHost` JSON serialization
- HostLocalStorage behavior
- validation logic
- settings persistence

Manual test:

- macOS SSH connection
- Linux SSH connection
- iOS SSH connection
- Android SSH connection
- password auth
- private key auth
- terminal resizing
- reconnect/disconnect
- credential deletion
- bottom nav bar (mobile)
- soft keyboard with terminal (mobile)

---

## 18. Error Handling Rules

Errors should be:

- clear
- human-readable
- calm
- actionable

Bad:

```txt
SocketException: OS Error 61
```

Better:

```txt
Could not connect to this host. Check the hostname, port, and network connection.
```

Do not expose raw technical errors as primary UX messages.

Raw errors can be logged locally during development only.

Never log secrets.

---

## 19. Code Style

Write Dart code that is:

- simple
- readable
- explicit
- small
- easy to modify

Prefer:

- small widgets
- small services
- clear method names
- plain models
- no clever abstractions

Avoid:

- huge widgets
- deeply nested UI
- hidden magic
- premature generics
- complex inheritance
- unnecessary mixins

---

## 20. Performance Goals

Target:

- app startup under 2 seconds
- terminal input feels instant
- idle memory under 250MB
- minimal unnecessary rebuilds
- smooth sidebar and command palette interactions

Use `ValueListenableBuilder` narrowly to avoid rebuilding entire screens.

---

## 21. Native Desktop Expectations

### macOS

Respect:

- CMD shortcuts
- native window behavior (via `window_manager`)
- Keychain expectations (via `flutter_secure_storage`)
- polished typography
- desktop spacing

### Linux

Respect:

- CTRL shortcuts
- Secret Service expectations (via `flutter_secure_storage`)
- `.desktop` distribution
- native window behavior where possible

### iOS

Respect:

- Human Interface Guidelines
- safe area insets (notch, home bar)
- Keychain for credentials (via `flutter_secure_storage`)
- foreground-only session lifecycle
- touch target sizing (minimum 44×44pt)
- soft keyboard awareness in terminal view
- bottom navigation bar instead of sidebar

### Android

Respect:

- Material Design conventions
- Android Keystore for credentials (via `flutter_secure_storage`)
- back gesture and navigation stack
- touch target sizing
- soft keyboard awareness in terminal view
- bottom navigation bar instead of sidebar

### Shared platform rules

When writing platform-specific code:

```dart
import 'dart:io';

if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
  // desktop-only: window_manager, keyboard shortcuts, sidebar layout
}

if (Platform.isIOS || Platform.isAndroid) {
  // mobile-only: bottom nav bar, soft keyboard handling
}
```

Never call `windowManager.*` on mobile — it will crash. Always guard with `Platform.isDesktop`.

---

## 22. Open Source Expectations

Shellbrick should be contributor-friendly.

Include eventually:

- clear README
- installation instructions
- development setup
- contribution guide
- issue templates
- PR template
- license

Recommended license:

- MIT or Apache 2.0

---

## 23. Decision Rules for Claude Code

When implementing anything, ask:

```txt
Does this make Shellbrick:
- faster?
- simpler?
- calmer?
- more native?
- more focused?
- more trustworthy?
```

If not:

- simplify it
- postpone it
- remove it

---

## 24. Important Constraints

Do not introduce:

- Riverpod
- Bloc
- Provider
- GetX
- Redux
- SQLite
- Drift
- Isar
- Hive
- Firebase
- Supabase
- backend APIs
- cloud sync
- accounts
- AI features

Unless explicitly requested later.

---

## 25. Final Instruction

Always preserve the MVP philosophy:

> Shellbrick is a focused, local-first, open-source SSH workspace.  
> Build the smallest beautiful version that works reliably.