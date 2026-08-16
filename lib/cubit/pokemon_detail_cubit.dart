import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_starter/core/bloc/safe_emit.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/cubit/pokemon_detail_state.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';

/// Loads one Pokémon for the detail route.
///
/// Scoped to the route, so there is exactly one instance per visit. The view
/// triggers [load] after its first frame — a constructor fetch could neither
/// be awaited nor stubbed, and a synchronous repository throw would have
/// escaped straight into the widget build.
class PokemonDetailCubit extends Cubit<PokemonDetailState>
    with SafeEmit<PokemonDetailState> {
  PokemonDetailCubit(this._repository, this.id)
    : super(const PokemonDetailLoading());

  final PokemonRepository _repository;
  final int id;

  /// Cancelled on close, so popping the route stops the in-flight fetch.
  CancelToken? _requestToken;

  Future<void> load() async {
    _requestToken?.cancel();
    final CancelToken token = CancelToken();
    _requestToken = token;
    // A no-op re-emit when already loading: Equatable states dedupe.
    emit(const PokemonDetailLoading());

    try {
      final Pokemon pokemon = await _repository.getById(id, cancelToken: token);
      safeEmit(PokemonDetailLoaded(pokemon));
    } on RequestCancelledException {
      // Route popped or reload superseded; nothing left to render.
    } on AppException catch (e, stackTrace) {
      addError(e, stackTrace);
      safeEmit(PokemonDetailFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      // No message: the widget layer localizes the generic fallback.
      safeEmit(const PokemonDetailFailure());
    }
  }

  @override
  Future<void> close() {
    _requestToken?.cancel();
    return super.close();
  }
}
