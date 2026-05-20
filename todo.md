# Shellbrick — MVP TODO Roadmap

# 1. Project Foundation

## Repository Setup

- [ ] Create GitHub repository
- [ ] Configure `.gitignore`
- [ ] Configure LICENSE
- [ ] Create README
- [ ] Define contribution guidelines
- [ ] Create issue templates
- [ ] Create PR template

---

## Flutter Desktop Setup

- [x] Create Flutter desktop project
- [x] Enable macOS support
- [x] Enable Linux support
- [ ] Configure app icons
- [ ] Configure app name
- [ ] Configure bundle identifiers
- [ ] Configure desktop window defaults

---

## Development Tooling

- [ ] Configure lints
- [ ] Configure formatting rules
- [ ] Configure analysis options
- [ ] Configure CI workflow
- [ ] Setup release builds
- [ ] Setup debug profiles

---

# 2. Application Shell

## App Bootstrap

- [x] Create `main.dart`
- [x] Setup app entrypoint
- [x] Setup theme system
- [x] Setup navigation structure
- [x] Setup app layout shell

---

## Window Management

- [x] Configure desktop window size
- [x] Configure minimum window size
- [x] Configure title bar behavior
- [x] Configure window persistence
- [x] Add fullscreen support

---

## Sidebar Layout

- [x] Create sidebar component
- [x] Add navigation items
- [x] Add active item states
- [x] Add collapsible behavior
- [x] Add responsive resizing

---

## Top Bar

- [x] Create top bar layout
- [x] Add search button
- [x] Add command palette trigger
- [x] Add settings button
- [x] Add session status indicator

---

# 3. Theme & Design System

## Color System

- [x] Create dark theme palette
- [x] Define semantic colors
- [x] Define accent colors
- [x] Define surface hierarchy

---

## Typography

- [ ] Configure Inter font
- [ ] Configure JetBrains Mono
- [ ] Define typography scale
- [ ] Define font weights
- [ ] Configure terminal typography

---

## Spacing System

- [x] Define spacing constants
- [ ] Define border radius system
- [ ] Define layout constraints

---

## Shared Components

- [ ] Create primary button
- [ ] Create icon button
- [ ] Create text input
- [ ] Create modal component
- [ ] Create search field
- [ ] Create empty state widget
- [ ] Create loading indicator

---

# 4. Host Management

## Data Models

- [x] Create `SshHost` model
- [x] Create `AuthType` enum
- [x] Add JSON serialization
- [x] Add validation helpers

---

## Local Storage

- [x] Setup SharedPreferences wrapper
- [x] Create host persistence service
- [x] Save hosts locally
- [x] Load hosts locally
- [x] Delete hosts
- [x] Update hosts

---

## Host List

- [x] Create host list page
- [x] Render host cards
- [x] Add empty state
- [ ] Add loading state
- [x] Add search functionality
- [x] Add favorites
- [x] Add recent connections
- [x] Add host grouping

---

## Host Creation

- [x] Create host form
- [x] Add hostname validation
- [x] Add port validation
- [x] Add auth type selection
- [x] Add tags input
- [x] Add notes field
- [x] Add save action

---

## Host Editing

- [x] Edit existing host
- [x] Delete host
- [x] Confirm deletion modal

---

# 5. Secure Credential Storage

## Secure Storage Integration

- [x] Setup flutter_secure_storage
- [x] Save passwords securely
- [x] Save passphrases securely
- [x] Load credentials securely
- [x] Delete credentials securely

---

## Private Key Support

- [x] Integrate file picker
- [x] Select private key path
- [x] Validate selected key
- [x] Persist key path

---

# 6. SSH Engine

## SSH Service

- [x] Create `SshService`
- [x] Connect to SSH host
- [x] Disconnect session
- [x] Handle SSH errors
- [ ] Handle reconnect logic

---

## Authentication

- [x] Implement password auth
- [x] Implement private key auth
- [ ] Implement SSH agent auth

---

## Connection Handling

- [x] Track active sessions
- [x] Track connection status
- [ ] Add latency measurement
- [x] Handle session disposal

---

# 7. Terminal System

## Terminal Integration

- [x] Integrate xterm.dart
- [x] Create terminal widget
- [x] Configure terminal theme
- [x] Configure terminal font

---

## Input/Output Binding

- [x] Pipe SSH output to terminal
- [x] Pipe terminal input to SSH
- [x] Handle terminal resize
- [x] Handle ANSI escape sequences

---

## Session Management

- [x] Create terminal sessions
- [x] Close terminal sessions
- [x] Track active session
- [x] Restore session focus

---

## Tabs

- [x] Create tab bar
- [x] Add session tabs
- [x] Switch tabs
- [x] Close tabs

---

# 8. Command Palette

## UI

- [ ] Create command palette modal
- [ ] Add search field
- [ ] Add keyboard navigation
- [ ] Add fuzzy matching

---

## Actions

- [ ] Search hosts
- [ ] Connect to host
- [ ] Open recent host
- [ ] Open settings
- [ ] Create new host

---

## Keyboard Shortcuts

- [ ] CMD + K on macOS
- [ ] CTRL + K on Linux
- [ ] ESC to close palette

---

# 9. Search & Navigation

## Host Search

- [x] Search by hostname
- [x] Search by tags
- [x] Search by IP
- [x] Search favorites

---

## Navigation UX

- [x] Keyboard navigation
- [x] Arrow key support
- [x] Focus management
- [x] Navigation shortcuts

---

# 10. Settings System

## Settings Storage

- [ ] Persist theme mode
- [x] Persist font size
- [x] Persist window preferences

---

## Settings UI

- [x] Create settings page
- [ ] Theme selection
- [x] Accent color selection
- [x] Terminal font size setting
- [x] Clear local data action

---

# 11. SFTP

## SFTP Engine

- [x] Connect SFTP session
- [x] Browse remote directories
- [x] Load file metadata

---

## File Operations

- [x] Upload file
- [x] Download file
- [x] Rename file
- [x] Delete file

---

## SFTP UI

- [x] Create file explorer
- [x] Add file list
- [x] Add upload action
- [x] Add download action

---

# 12. Port Forwarding

## Tunnel Engine

- [x] Create local tunnel
- [x] Close local tunnel
- [x] Track active tunnels

---

## Tunnel UI

- [x] Create tunnel modal
- [x] Add active tunnel list
- [x] Add enable/disable actions

---

# 13. UX Polish

## Animations

- [ ] Add page transitions
- [ ] Add hover animations
- [ ] Add modal animations
- [ ] Add focus animations

---

## Empty States

- [ ] No hosts
- [ ] No favorites
- [ ] No recent sessions
- [ ] No search results

---

## Loading States

- [ ] SSH connecting
- [ ] SFTP loading
- [ ] Host loading
- [ ] Terminal initializing

---

## Error States

- [ ] Connection failed
- [ ] Invalid credentials
- [ ] SSH timeout
- [ ] File upload failed

---

# 14. Native Desktop Features

## macOS

- [x] Keychain integration
- [x] Native title bar behavior
- [x] Native shortcuts
- [x] Dock integration

---

## Linux

- [x] Secret Service integration
- [ ] DBus support
- [x] Desktop entry support

---

# 15. Performance

## Optimization

- [ ] Optimize terminal rendering
- [ ] Optimize startup time
- [ ] Reduce rebuilds
- [ ] Optimize memory usage

---

## Targets

- [ ] Startup under 2 seconds
- [ ] Smooth terminal typing
- [ ] Low idle memory usage

---

# 16. Testing

## Unit Tests

- [ ] Host serialization tests
- [ ] SSH service tests
- [ ] Storage tests

---

## Widget Tests

- [ ] Host list tests
- [ ] Terminal widget tests
- [ ] Form validation tests

---

## Manual Testing

- [ ] macOS testing
- [ ] Linux testing
- [ ] SSH auth testing
- [ ] Terminal stress testing

---

# 17. Release Preparation

## Branding

- [ ] Finalize logo
- [ ] Finalize app icon
- [ ] Finalize screenshots

---

## Documentation

- [ ] Installation guide
- [ ] Development guide
- [ ] Contribution guide
- [ ] Keyboard shortcuts guide

---

## Distribution

- [ ] macOS release build
- [ ] Linux AppImage
- [ ] GitHub releases
- [ ] Changelog generation

---

# 18. MVP Completion Criteria

The MVP is complete when users can:

- [ ] Add SSH hosts
- [ ] Save hosts locally
- [ ] Authenticate securely
- [ ] Open SSH terminal sessions
- [ ] Manage multiple sessions
- [ ] Use keyboard-first workflows
- [ ] Use SFTP
- [ ] Use port forwarding
- [ ] Use the app daily reliably

---

# 19. Engineering Rule

For every feature ask:

```txt
Does this make Shellbrick:
- faster?
- simpler?
- calmer?
- more native?
- more focused?
```

If not:
- simplify it
- postpone it
- remove it