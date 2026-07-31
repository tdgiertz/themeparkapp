# themeparkapp

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Project conventions added

- Feature-first folder layout: `lib/features/...` and `lib/core` for shared utilities.
- Environment config: use `--dart-define-from-file=config/dev.json` or `config/prod.json`.

Example run for dev:

```bash
flutter run --dart-define-from-file=config/dev.json
```

Example run for production:

```bash
flutter run --release --dart-define-from-file=config/prod.json
```

Linting: switched to `very_good_analysis` in `analysis_options.yaml` for stricter rules.

Localization: ARB files live under `lib/l10n/` and Flutter's `gen_l10n` will generate localization classes when you run the app or `flutter pub get`.
