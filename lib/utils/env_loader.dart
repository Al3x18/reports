import 'package:dotenv/dotenv.dart';

DotEnv? _env;

/// Returns the value for [key] from keys.env, or empty string if not set.
/// Loads keys.env from project root on first call (when running from IDE/CLI).
String getEnv(String key) {
  _env ??= () {
    try {
      return DotEnv(quiet: true)..load(['keys.env']);
    } catch (_) {
      return DotEnv(quiet: true);
    }
  }();
  final env = _env;
  return (env?[key] ?? '').trim();
}
