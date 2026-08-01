# Test Coverage & Gap Analysis

Based on the latest coverage report, the overall health of the test suite is excellent in pure business logic and models, but there are notable gaps in UI layers, Riverpod providers, and app integration.

Here is a breakdown of the areas that could use more testing, organized by priority.

## 🔴 High Priority (Significant Missing Coverage)

These files represent core user flows or contain significant amounts of untested logic.

### 1. The Main App Entrypoint (`main.dart`)
- **Coverage:** 5.4% (382 lines missed)
- **Why it matters:** Contains top-level routing (GoRouter setup), Riverpod `ProviderScope` configuration, theme initialization, and error handling.
- **Action:** Add **Integration Tests** to verify the app can bootstrap correctly, initialize routing, and present the initial splash/dashboard screens.

### 2. Park Explorers & Complex UI
- **`lib/features/search/search_page.dart`** (42.5% coverage, 314 lines missed)
- **`lib/features/park/park_page.dart`** (55.2% coverage, 437 lines missed)
- **`lib/features/parks/parks_page.dart`** (63.1% coverage, 220 lines missed)
- **`lib/features/park/facility_detail_page.dart`** (72.9% coverage, 163 lines missed)
- **Why it matters:** These are the largest widgets in the app. The missing coverage likely corresponds to edge cases, loading/error states, empty states, and complex interactions (like tapping markers, opening bottom sheets, or resizing the window on desktop/tablet).
- **Action:** Add **Widget Tests** focusing specifically on:
  - Responsive layouts (verify behavior when screen size changes)
  - Simulating user gestures (scroll, tap) and checking that state changes reflect on the UI.
  - Ensuring fallback widgets render when data is null.

### 3. Totally Untested Widgets & Components
- **`facility_detail_sheet.dart`** (0.0% coverage, 231 lines missed)
- **`area_chart.dart`** (0.0% coverage, 98 lines missed)
- **Why it matters:** These files currently have no tests. The `facility_detail_sheet.dart` contains complex bottom sheet interaction logic, and `area_chart.dart` is a custom painter/charting widget.
- **Action:** 
  - Add **Golden Tests** for `area_chart.dart` to ensure visual regressions don't break the chart rendering.
  - Add **Widget Tests** for the `facility_detail_sheet.dart` to ensure it parses facility data properly and renders buttons/details correctly.

## 🟡 Medium Priority (Logic & Providers)

### 1. Data Layer & Repositories
- **`lib/repositories/repositories.dart`** (0.0% coverage, 35 lines missed)
- **`lib/features/parks/providers/park_providers.dart`** (28.8% coverage, 42 lines missed)
- **Why it matters:** Repositories and providers are the backbone of data flow. If they fail, the UI fails silently.
- **Action:** Add **Unit Tests** for `park_providers.dart` using a `ProviderContainer` to verify derived state (e.g., filtering logic, wait time aggregations). Use `package:mockito` or mock repositories to test `repositories.dart` behaviors, including HTTP/JSON parsing exceptions.

## 🟢 Low Priority (Housekeeping)

### 1. Exclude Generated Code from Coverage
Generated files artificially lower the coverage score and don't need manual tests.
- `lib/features/parks/models/*.g.dart`
- `lib/l10n/app_localizations_*.dart`
- **Action:** Add `// coverage:ignore-file` to the top of generated files, or configure `lcov` filtering to ignore `*.g.dart` and `l10n/` directories.

## 📝 Recommended Next Steps

1. **Golden Tests for Charts:** Start with `area_chart.dart` since custom paints are prone to visual bugs.
2. **Widget Tests for Bottom Sheets:** Add tests for `facility_detail_sheet.dart`.
3. **Provider Unit Tests:** Test the filtering logic inside `park_providers.dart`.
4. **Integration Tests:** Write a basic `app_test.dart` integration test to cover `main.dart` routing and initialization.
