import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// The deployment flavour. An enum rather than raw strings compared at each
/// call site, where a typo would silently make every `is*` check false.
enum Environment { development, staging, production }

abstract final class AppConfig {
  static String get apiBaseUrl =>
      _get('API_BASE_URL') ?? 'https://pokeapi.co/api/v2';

  /// Anything unrecognized (including absent) reads as development. The
  /// warning for a typo is emitted once by [load], not here: this getter is
  /// cheap and silent because callers may hit it inside a `build`.
  static Environment get environment => switch (_get('ENVIRONMENT')) {
    'staging' => Environment.staging,
    'production' => Environment.production,
    _ => Environment.development,
  };

  static bool get isDevelopment => environment == Environment.development;
  static bool get isStaging => environment == Environment.staging;
  static bool get isProduction => environment == Environment.production;

  /// Timeouts for the shared Dio instance. Dio's default is no timeout at
  /// all, which on a half-open connection means hanging for minutes.
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);

  /// Page size for the paginated list and for search hydration.
  static const int pageSize = 20;

  /// Large enough to fetch the entire name index (~1350 entries) in one
  /// request.
  static const int nameIndexLimit = 100000;

  /// `dotenv.env` throws when [load] never ran (or failed), which would turn
  /// the defaults above into dead code and crash the caller instead.
  static String? _get(String key) =>
      dotenv.isInitialized ? dotenv.maybeGet(key) : null;

  // Required: the caller decides the flavour (main wires it to ENV_FILE).
  static Future<void> load({required String fileName}) async {
    try {
      await dotenv.load(fileName: fileName);
    } catch (_) {
      // A missing or unreadable .env is survivable: every getter has a
      // default, so the app must boot rather than die before runApp.
    }
    _warnIfEnvironmentUnrecognized();
  }

  /// Startup is the only place a misspelled `ENVIRONMENT` can be reported
  /// where someone will read it — and reported once, rather than per access.
  static void _warnIfEnvironmentUnrecognized() {
    final String? raw = _get('ENVIRONMENT');
    if (raw == null ||
        Environment.values.any((Environment e) => e.name == raw)) {
      return;
    }
    developer.log(
      'Unrecognized ENVIRONMENT "$raw", falling back to development',
      name: 'config',
    );
  }
}
