# Shellbrick — Technical Specification (MVP)

# 1. Overview

Shellbrick is a minimalist open-source SSH workspace built with Flutter and Dart.

The MVP architecture prioritizes:

- simplicity
- fast iteration
- native desktop UX
- low abstraction
- minimal dependencies
- maintainability

The architecture intentionally avoids over-engineering.

---

# 2. Technology Stack

## Frontend

- Flutter Desktop
- Dart

## Target Platforms

### MVP
- macOS
- Linux

### Post-MVP
- Windows

---

# 3. Core Dependencies

# 3.1 SSH Engine

## Package

```yaml
dartssh2:
```

## Responsibilities

- SSH connection
- shell sessions
- authentication
- SFTP
- port forwarding

---

# 3.2 Terminal Emulator

## Package

```yaml
xterm:
```

## Responsibilities

- terminal rendering
- ANSI escape sequences
- keyboard input
- terminal buffering

---

# 3.3 Local Storage

## Package

```yaml
shared_preferences:
```

## Responsibilities

Store:
- hosts
- tags
- UI preferences
- recent connections
- app settings

---

# 3.4 Secure Storage

## Package

```yaml
flutter_secure_storage:
```

## Responsibilities

Store:
- passwords
- passphrases
- sensitive credentials

---

# 3.5 File Picker

## Package

```yaml
file_picker:
```

## Responsibilities

- select SSH private keys
- select import/export files

---

# 3.6 Desktop Window Management

## Package

```yaml
window_manager:
```

## Responsibilities

- custom window sizing
- window controls
- desktop polish
- title bar behavior

---

# 4. Architecture Philosophy

Shellbrick uses a very lightweight architecture.

No:
- Bloc
- Riverpod
- Provider
- Redux
- GetX
- Clean Architecture over-abstraction

The MVP prioritizes:
- speed of development
- readability
- low cognitive load

---

# 5. Application Structure

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
│   ├── utils.dart
│   └── extensions.dart
│
├── features/
│
│   ├── hosts/
│   │   ├── models/
│   │   │   └── ssh_host.dart
│   │   │
│   │   ├── data/
│   │   │   └── host_local_storage.dart
│   │   │
│   │   ├── controllers/
│   │   │   └── host_controller.dart
│   │   │
│   │   ├── views/
│   │   │   ├── host_list_page.dart
│   │   │   └── host_form_page.dart
│   │   │
│   │   └── widgets/
│   │
│   ├── terminal/
│   │   ├── models/
│   │   │   └── terminal_session.dart
│   │   │
│   │   ├── services/
│   │   │   └── ssh_service.dart
│   │   │
│   │   ├── controllers/
│   │   │   └── terminal_controller.dart
│   │   │
│   │   ├── views/
│   │   │   └── terminal_page.dart
│   │   │
│   │   └── widgets/
│   │
│   └── settings/
│       ├── data/
│       │   └── settings_storage.dart
│       │
│       ├── controllers/
│       │   └── settings_controller.dart
│       │
│       ├── views/
│       │   └── settings_page.dart
│       │
│       └── widgets/
│
└── shared/
    ├── widgets/
    ├── layouts/
    └── themes/
```

---

# 6. State Management

## Strategy

Use only:
- `setState`
- `ValueNotifier`
- `ValueListenableBuilder`

---

# 6.1 Local State

Use `setState` for:
- form inputs
- modal visibility
- hover states
- temporary UI interactions

Example:

```dart
setState(() {
  isLoading = true;
});
```

---

# 6.2 Shared Feature State

Use `ValueNotifier` for:
- hosts list
- active session
- settings
- favorites
- recent hosts

Example:

```dart
final hostsNotifier = ValueNotifier<List<SshHost>>([]);
```

UI binding:

```dart
ValueListenableBuilder(
  valueListenable: hostsNotifier,
  builder: (context, hosts, _) {
    return HostsList(hosts: hosts);
  },
)
```

---

# 7. Data Models

# 7.1 SSH Host

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

---

# 7.2 Authentication Type

```dart
enum AuthType {
  password,
  privateKey,
  sshAgent,
}
```

---

# 8. Local Storage Strategy

# 8.1 SharedPreferences

Used for non-sensitive data.

## Stored Keys

```txt
shellbrick.hosts
shellbrick.themeMode
shellbrick.recentHosts
shellbrick.windowPreferences
```

---

# 8.2 Hosts Storage Format

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

---

# 8.3 Secure Storage

Sensitive data stored using:

```yaml
flutter_secure_storage
```

## Stored Keys

```txt
shellbrick.host.{hostId}.password
shellbrick.host.{hostId}.privateKeyPassphrase
```

Important:
- never store passwords in SharedPreferences
- never store private key contents
- only store key paths

---

# 9. Main Services

# 9.1 HostLocalStorage

Responsibilities:
- load hosts
- save hosts
- update hosts
- delete hosts
- persist recent connections

---

# 9.2 SshService

Responsibilities:
- establish SSH connection
- authenticate user
- create shell session
- pipe streams
- close session
- reconnect session

---

# 9.3 TerminalController

Responsibilities:
- bind xterm.dart to SSH stream
- write user input to remote shell
- handle terminal resize
- dispose safely

---

# 10. MVP Screens

# 10.1 Host List Page

Features:
- list hosts
- search hosts
- favorite hosts
- connect button
- edit/delete hosts

---

# 10.2 Host Form Page

Fields:
- host name
- hostname
- port
- username
- auth type
- password/private key path
- tags

---

# 10.3 Terminal Page

Features:
- terminal emulator
- session status
- reconnect session
- split tabs later

---

# 10.4 Settings Page

Features:
- dark/light mode
- terminal font size
- clear local data
- app information

---

# 11. SSH Connection Flow

```txt
User opens app
  ↓
App loads hosts from SharedPreferences
  ↓
User selects host
  ↓
App retrieves credentials from secure storage
  ↓
SshService establishes SSH connection
  ↓
xterm.dart terminal opens
  ↓
SSH output streams into terminal
  ↓
User input streams into remote shell
```

---

# 12. Security Rules

## Requirements

- passwords encrypted
- no plaintext secrets
- no telemetry by default
- no remote servers in MVP
- no cloud dependency

---

# 13. Performance Goals

## Startup Time

Target:
- under 2 seconds

## Memory Usage

Target:
- under 250MB idle

## UX

Terminal typing must feel instant.

---

# 14. What NOT to Build

Do NOT build in MVP:

- cloud sync
- accounts
- collaboration
- plugins
- AI features
- Kubernetes integration
- Docker integration
- SQLite abstraction
- complex architecture
- advanced dependency injection

---

# 15. Recommended Development Order

# Phase 1 — Desktop Foundation

- Flutter desktop setup
- app shell
- dark theme
- sidebar layout

---

# Phase 2 — Host Management

- create host
- edit host
- delete host
- persist hosts locally

---

# Phase 3 — Secure Credentials

- secure password storage
- private key path support

---

# Phase 4 — SSH Connectivity

- connect via dartssh2
- password auth
- private key auth

---

# Phase 5 — Terminal Integration

- integrate xterm.dart
- pipe SSH streams
- keyboard input

---

# Phase 6 — UX Improvements

- search
- favorites
- recent hosts
- keyboard shortcuts

---

# Phase 7 — Advanced Features

- SFTP
- port forwarding

---

# 16. Engineering Philosophy

For MVP:

> Make it work.
> Make it simple.
> Make it beautiful.
> Do not over-engineer.