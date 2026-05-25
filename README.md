# Xell

A calm, open-source SSH workspace built for developers who value focus, speed, and native platform quality.

![License](https://img.shields.io/badge/license-MIT-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20iOS%20%7C%20Android-lightgrey)

---

## What it is

Xell is an open-source SSH workspace on its way to becoming a full DevOps toolkit. It provides:

- **Host management** — store and organize your SSH hosts locally
- **Integrated terminal** — full xterm-compatible sessions via `dartssh2`
- **SFTP browser** — browse, upload, download, rename, and delete remote files
- **Local port forwarding** — tunnel remote ports to localhost
- **Command palette** — keyboard-first host search and navigation (`⌘K` / `Ctrl+K`)
- **Secure credentials** — passwords and passphrases stored in the system keychain, never in plain text
- **Local-first** — no accounts, no cloud sync, no telemetry

Inspired by Linear, Raycast, Ghostty, and Warp.

### Roadmap (post-MVP)

- Docker container management
- Kubernetes cluster access
- AI-assisted terminal workflows
- Plugin / extension system

---

## Platforms

| Platform | Status     |
|----------|------------|
| macOS    | Supported  |
| Linux    | Supported  |
| iOS      | Supported  |
| Android  | Supported  |
| Windows  | Post-MVP   |

---

## Installation

### One-line install (macOS and Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/ildysilva/xell/main/install.sh | bash
```

Or pin to a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/ildysilva/xell/main/install.sh | bash -s -- --version v0.1.0
```

**macOS** — installs to `/Applications/Xell.app`. Removes the Gatekeeper quarantine flag automatically so the app opens without friction (even when unsigned during early releases).

**Linux** — installs the full bundle to `~/.local/share/xell/` and links the binary to `~/.local/bin/xell`.

### Manual install

Download the latest release from [GitHub Releases](https://github.com/ildysilva/xell/releases):

| Platform | File |
|---|---|
| macOS | `Xell-v*-macos.dmg` |
| Linux x64 | `Xell-v*-linux-x64.tar.gz` |

Homebrew cask (coming soon — requires notarized build):
```bash
brew install --cask xell
```

---

## Building from source

### Requirements

- Flutter 3.x (stable channel)
- Dart 3.x
- Xcode (macOS/iOS)
- Android Studio or NDK (Android)

### Install Flutter

Follow the official guide: https://docs.flutter.dev/get-started/install

### Clone and run

```bash
git clone https://github.com/ildysilva/xell.git
cd xell
flutter pub get
flutter run -d macos       # macOS
flutter run -d linux       # Linux
flutter run -d ios         # iOS simulator or device
flutter run -d android     # Android emulator or device
```

### Release builds

```bash
./scripts/build_macos.sh        # → dist/Xell-v*.dmg
./scripts/build_linux.sh        # → dist/Xell-v*-linux-x64.tar.gz
./scripts/release.sh 0.1.0      # tag + push → triggers GitHub Actions release
```

### macOS — signing for local development

If you don't have an Apple Developer account, open the project in Xcode and set the signing identity to **Sign to Run Locally**:

1. Open `macos/Runner.xcworkspace` in Xcode
2. Select the **Runner** target → **Signing & Capabilities**
3. Set **Signing Certificate** to **Sign to Run Locally**

---

## Development

### Folder structure

```
lib/
├── main.dart
├── app/                    # App shell, theme, routes
├── core/                   # Constants, exceptions, utilities
├── features/
│   ├── hosts/              # Host management
│   ├── terminal/           # SSH terminal sessions
│   ├── sftp/               # SFTP file browser
│   ├── port_forwarding/    # Local port forwarding
│   ├── command_palette/    # Command palette overlay
│   └── settings/           # App settings
└── shared/                 # Shared widgets and layouts
```

### State management

Xell uses plain `ValueNotifier` + `ValueListenableBuilder`. No Riverpod, Bloc, Provider, or GetX.

### Key packages

| Package | Purpose |
|---------|---------|
| `dartssh2` | SSH and SFTP client |
| `xterm` | Terminal emulator widget |
| `flutter_secure_storage` | Keychain/Keystore credential storage |
| `shared_preferences` | Non-sensitive local settings |
| `file_picker` | Private key file selection |
| `window_manager` | Native window control (desktop only) |

### Running analysis

```bash
flutter analyze
flutter test
```

---

## Security

- Passwords and key passphrases are stored exclusively in the system keychain (`flutter_secure_storage`)
- Private key file paths are stored locally — key contents are never copied or transmitted
- No credentials are logged, printed, or sent anywhere
- No telemetry, no analytics, no accounts

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

MIT — see [LICENSE](LICENSE).
