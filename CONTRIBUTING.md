# Contributing to Xell

Thank you for taking the time to contribute. Xell is a focused, local-first SSH workspace and we want to keep it that way.

---

## Before you start

Read the project identity in [CLAUDE.md](CLAUDE.md). It describes exactly what Xell is, what it is not, and the constraints that guide every decision.

The short version:

> Xell is a focused SSH workspace for developers who care about speed, calm UX, and open-source transparency. It is not a generic DevOps dashboard.

---

## What we welcome

- Bug fixes
- Performance improvements
- UX polish aligned with the design philosophy
- Platform-specific quality improvements (macOS, Linux, iOS, Android)
- Missing MVP features listed in the project roadmap
- Documentation improvements
- Test coverage for core logic
- Post-MVP DevOps integrations (Docker, Kubernetes, AI-assisted workflows) — open an issue first to align on approach

## MVP vs. post-MVP scope

The MVP is a focused SSH workspace. Once the MVP is stable, Xell will grow into a broader DevOps toolkit. Planned post-MVP directions include:

- Docker container management
- Kubernetes cluster access
- AI-assisted terminal workflows
- Plugin / extension system

Contributions in these areas are welcome **after the MVP is complete** and only with prior discussion in an issue to align on design and scope.

## What we will decline

- Cloud sync or user accounts (data stays local-first)
- External state management libraries (Riverpod, Bloc, Provider, GetX)
- External databases (SQLite, Drift, Isar, Hive) without a compelling reason
- Backend APIs or remote dependencies that break the local-first guarantee
- Features that add complexity without clear user value

If you are unsure whether a contribution fits, open an issue first.

---

## Development setup

```bash
git clone https://github.com/ildysilva/xell.git
cd xell
flutter pub get
flutter run -d macos
```

Requires Flutter 3.x stable and Dart 3.x.

---

## Workflow

1. Fork the repository
2. Create a branch: `git checkout -b feat/your-feature` or `fix/your-fix`
3. Make your changes — keep commits focused and small
4. Run `flutter analyze` and `flutter test` — both must pass
5. Open a pull request against `main`

---

## Code style

- Simple, readable, explicit Dart
- Small widgets, small services, clear method names
- No unnecessary abstractions or premature generics
- `ValueNotifier` + `ValueListenableBuilder` for shared state — no external state packages
- Feature-first folder structure under `lib/features/`
- No comments that describe what the code does — only write comments for non-obvious constraints or workarounds

Run the formatter before committing:

```bash
dart format lib/
```

---

## Security contributions

If you discover a security vulnerability, please do **not** open a public issue. Email the maintainers directly or use GitHub's private vulnerability reporting.

Never commit credentials, private keys, or secrets of any kind.

---

## Pull request checklist

- [ ] `flutter analyze` passes with no issues
- [ ] `flutter test` passes
- [ ] No new external packages introduced without prior discussion
- [ ] No credentials, secrets, or sensitive data included
- [ ] Changes are consistent with the design philosophy in CLAUDE.md
- [ ] PR description explains the problem and the approach

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
