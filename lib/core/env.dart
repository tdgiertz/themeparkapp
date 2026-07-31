/// Compile-time environment values. These are provided via
/// `--dart-define` or `--dart-define-from-file` when launching the app.
class Env {
  /// API base url supplied at compile time via `API_URL`.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.dev',
  );

  /// API key supplied at compile time via `API_KEY`.
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'DEV_KEY',
  );
}
