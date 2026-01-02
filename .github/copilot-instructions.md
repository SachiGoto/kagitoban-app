The following guidance helps AI coding agents contribute to kagitoban (a small Flutter app).

- Project type: Flutter (Dart >=3.3.1). See `pubspec.yaml` for dependencies and `flutter` tooling settings.

- Big picture
  - Entry point: `lib/main.dart` constructs a `SettingsController` (backed by `SettingsService`) and runs `MyApp` from `lib/src/app.dart`.
  - App shell: `lib/src/app.dart` builds the `MaterialApp`, sets localization delegates, supported locales, theme/darkTheme, and `onGenerateRoute` to resolve three main routes: `SampleItemListView` (`/`), `SampleItemDetailsView` (`/sample_item`), and `SettingsView` (see `lib/src/settings`).
  - State pattern: small controller+service pattern — `SettingsController` (ChangeNotifier) mediates UI and `SettingsService` (currently in-memory stub). Prefer adding persistence in `SettingsService` (e.g., shared_preferences) rather than changing controller semantics.

- Key files to inspect when making changes
  - `lib/main.dart` — app boot, initialization ordering (await settingsController.loadSettings() before runApp to avoid theme flicker).
  - `lib/src/app.dart` — routing, localization, theme wiring, restorationScopeId usage.
  - `lib/src/settings/*` — controller/service/view pattern used across the app.
  - `lib/src/sample_feature/*` — example feature demonstrating navigation, restoration, and asset usage.
  - `l10n.yaml` and `lib/src/localization` — app uses Flutter gen_l10n; generated files live under `lib/generated` via build step (run `flutter gen-l10n` or `flutter pub get`+`flutter run`).

- Coding patterns & conventions (project-specific)
  - Restoration APIs: navigation and certain widgets use restorable navigation/restorationId (see `Navigator.restorablePushNamed` and `restorationId` in `sample_item_list_view.dart`). Preserve restoration ids when refactoring to maintain state restoration.
  - Controller-service separation: controllers expose ChangeNotifier and own in-memory state; persist in `SettingsService` only. Do not make SettingsService public API consumers use internal fields directly (it's intentionally private to the controller in `SettingsController`).
  - Localization: strings are generated via `flutter_gen` (see imports: `package:flutter_gen/gen_l10n/app_localizations.dart`). Edit `.arb` files under `lib/src/localization` and run the gen step rather than editing generated code.
  - Theme loading: `main.dart` awaits `settingsController.loadSettings()` before calling `runApp` to avoid theme flash — keep this ordering for any additional startup initialization.
  - Assets: images live in `assets/images/` and are declared in `pubspec.yaml`. Use `AssetImage('assets/images/...')` as in `sample_item_list_view.dart`.

- Build/test/debug workflows
  - Standard Flutter commands apply. Common quick commands:
    - flutter analyze (lints via `flutter_lints`) — run locally.
    - flutter pub get — fetch packages and trigger generated code hooks.
    - flutter run — start app on selected device.
    - flutter test — run unit/widget tests in `test/`.
  - Localization generation: run `flutter pub get` then `flutter gen-l10n` or rely on `flutter run` which will generate localization code when `generate: true` is set in `pubspec.yaml`.
  - iOS/macOS/Android platform projects exist; use platform-specific tooling when debugging native crashes (Xcode for iOS/macOS, Android Studio/adb for Android).

- Integration and external dependencies
  - Currently minimal external deps (only flutter, flutter_localizations). If adding persistence, prefer `shared_preferences` for settings; document and wire through `SettingsService`.
  - Generated localization code is an integration point: imports like `package:flutter_gen/gen_l10n/app_localizations.dart` are used by `lib/src/app.dart`.

- Small examples to follow
  - Add a new feature route: follow `lib/src/sample_feature` pattern — create view Widget, add static `routeName`, and update `onGenerateRoute` in `lib/src/app.dart`.
  - Persist settings: implement `SettingsService.themeMode()` and `updateThemeMode(...)` using `shared_preferences` and keep `SettingsController` unchanged.

- What NOT to change
  - Do not edit generated localization files. Edit `.arb` files under `lib/src/localization` and regenerate.
  - Do not remove or rename restoration ids unless intentionally resetting restoration behavior; these are part of the app's expected UX.

If anything is unclear or you'd like me to expand examples (e.g., add a persistence implementation or CI build steps), tell me which area to iterate on.
