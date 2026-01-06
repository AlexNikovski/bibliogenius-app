# BiblioGenius App - Flutter

Cross-platform mobile and desktop application for managing your library.

## Tech Stack

- **Framework**: Flutter/Dart
- **Backend**: Rust (embedded via FFI with Flutter Rust Bridge)
- **Build System**: Cargokit (automatic Rust compilation)
- **State Management**: Provider
- **Local Storage**: SQLite (via Rust backend)
- **HTTP Client**: Dio

## Platforms

- Android
- iOS
- Windows
- macOS
- Linux
- Web (limited features, HTTP mode only)

## Features

- **Embedded Rust backend** — No separate server needed!
- Browse and search books
- Add/edit books via ISBN scan
- Barcode scanning (ISBN lookup)
- Offline-first with local SQLite database
- P2P sharing with other BiblioGenius users (mDNS discovery)
- Gamification and achievements

## 🏗️ Architecture

The Rust backend is **embedded directly** into the Flutter app via FFI (Foreign Function Interface):

```text
┌────────────────────────────────────┐
│  BiblioGenius App                  │
│  ├── Flutter UI (Dart)             │
│  └── Rust Backend (via FFI)        │
│      └── SQLite Database           │
└────────────────────────────────────┘
```

**Cargokit** (in `rust_builder/cargokit/`) handles automatic Rust compilation when you run `flutter run`.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Rust](https://rustup.rs/) (for native builds)
- Xcode (macOS/iOS) or Android Studio (Android)

### Run the App

```bash
# Get dependencies
flutter pub get

# Run on desktop (Rust compiles automatically!)
flutter run -d macos

# Run on mobile
flutter run -d ios
flutter run -d android
```

> **Note**: You do NOT need to run `cargo run` separately. The Rust backend is compiled automatically by Cargokit when you run `flutter run`.

### Build for Release

```bash
flutter build apk      # Android
flutter build ios      # iOS
flutter build macos    # macOS
```

## Development

### Modifying Rust Code

Edit files in `../bibliogenius/src/`, then run `flutter run`. Changes are detected and recompiled automatically.

### Troubleshooting

```bash
# Clean build (if you encounter strange errors)
flutter clean
flutter pub get
flutter run -d macos

# Full clean including Rust cache
cd ../bibliogenius && cargo clean
cd ../bibliogenius-app && flutter clean && flutter run -d macos
```

See [DEVELOPMENT_SETUP.md](../bibliogenius-docs/docs/technical/DEVELOPMENT_SETUP.md) for detailed documentation.

## 🗺️ Roadmap

| Version | Status | Focus |
|---------|--------|-------|
| **In Development** | ✅ Current | Personal library + LAN sync |
| v1.0.0 | Q1 2026 | Stable P2P on local network |
| v2.0.0 | Q2-Q3 2026 | Global P2P + Social Features |

## Repository

<https://github.com/bibliogenius/bibliogenius-app>
