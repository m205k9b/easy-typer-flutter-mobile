# easy_typer_flutter

## Commands

- Fetch dependencies: `flutter pub get`
- Analyze: `flutter analyze`
- Run all tests: `flutter test`
- Run the controller tests only: `flutter test test/practice_controller_test.dart`
- Run on a connected device: `flutter run`

## Application Structure

- This is a single Flutter application; `lib/main.dart` initializes `LocalRepository` before constructing `EasyTyperApp`.
- `lib/app.dart` owns the app-wide `AppState` and bottom-tab shell. Pass its existing `AppState` to screens rather than creating per-screen application state.
- Practice behavior and its unit coverage live in `lib/practice_controller.dart` and `test/practice_controller_test.dart`; extend that test file when changing typing, timing, retry, or record-completion logic.
- `lib/data/local_repository.dart` persists records and result-format settings through `shared_preferences`. Treat `practice_records_v1` and `result_format_v1` as persisted data contracts; add migration handling before changing their serialized model or key.

## Platform Notes

- Android is configured with Kotlin Gradle files and Java/Kotlin 17 in `android/app/build.gradle.kts`.
- There is no CI, task runner, integration-test suite, code generation, or additional local instruction file in this repository.
