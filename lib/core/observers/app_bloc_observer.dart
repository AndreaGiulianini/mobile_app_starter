import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

/// Logs every bloc lifecycle event in debug builds. Installed once in `main`.
class AppBlocObserver extends BlocObserver {
  final Logger _logger = Logger(printer: SimplePrinter());

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      _logger.t('${bloc.runtimeType} created');
    }
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      _logger.d('${bloc.runtimeType} <- $event');
    }
  }

  /// Fires for cubits too, unlike `onTransition`.
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      _logger.i(
        '${bloc.runtimeType}: '
        '${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    // Never debug-gated: hydration failures and every addError land here, and
    // release builds used to discard them all. Swap in a crash reporter when
    // one is adopted.
    developer.log(
      '${bloc.runtimeType} failed',
      name: 'bloc',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    if (kDebugMode) {
      _logger.t('${bloc.runtimeType} closed');
    }
  }
}
