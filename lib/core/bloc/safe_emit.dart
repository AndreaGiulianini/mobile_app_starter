import 'package:flutter_bloc/flutter_bloc.dart';

/// Guards post-`await` emits: by then the owning widget may already have
/// disposed the bloc, and emitting after close throws.
///
/// One mixin instead of the same private helper copy-pasted per cubit.
mixin SafeEmit<State> on BlocBase<State> {
  void safeEmit(State state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
