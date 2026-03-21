---
title: Contributing
description: How to contribute to Omnigram
---

Omnigram welcomes contributions! The project has two main components: a Go backend server and a Flutter client app.

## Repository Structure

```
omnigram/
├── server/     # Go backend (Gin + GORM)
├── app/        # Flutter client (forked from Anx Reader, MIT)
├── site/       # Website and docs (Astro + Starlight)
├── docs/       # Design documents and API specs
└── Makefile    # Root-level build orchestration
```

## Development Setup

### Server (Go)

Requirements: Go 1.23+

```bash
cd server
make          # Build server binary
make docker   # Build Docker image
```

The server uses Gin for HTTP routing, GORM for database access, and BadgerDB for key-value storage. Entry point is at `server/cmd/omni-server/`.

### App (Flutter)

Requirements: Flutter 3.41+, Dart 3.11+

```bash
cd app
flutter pub get                          # Install dependencies
flutter gen-l10n                         # Generate localizations
dart run build_runner build --delete-conflicting-outputs  # Code generation
flutter analyze lib/                     # Static analysis
flutter build apk --split-per-abi       # Build Android APK
```

Or use the root Makefile shortcuts:

```bash
make app-deps       # flutter pub get
make app-codegen    # l10n + build_runner
make app-analyze    # flutter analyze
make app-build-apk  # Build APK
```

The app uses Riverpod v2 for state management with code generation. Models use freezed and json_serializable.

### Website

Requirements: Node.js 18+

```bash
cd site
npm install
npm run dev     # Local dev server
npm run build   # Production build
```

## Code Conventions

- **Language:** Code in English; comments and docs may use Chinese
- **Code generation:** Run codegen after modifying providers, models, or localization files
- **Formatting:** Use standard formatters (`gofmt` for Go, `dart format` for Dart)
- **Linting:** Run `flutter analyze lib/` before submitting app changes

## Pull Request Process

1. Fork the repository and create a feature branch
2. Make your changes with clear, descriptive commits
3. Ensure the project builds and passes analysis:
   - Server: `cd server && make`
   - App: `make app-analyze`
4. Open a pull request against `main`
5. Describe what your PR does and why

## Versioning

Git tags (`v*.*.*`) trigger CI release pipelines:
- **Server:** Docker images are built for `arm64` and `amd64`
- **App:** Android APK is built and signed automatically

## License

- Server: MIT
- App: MIT (forked from [Anx Reader](https://github.com/Anxcye/anx-reader))
