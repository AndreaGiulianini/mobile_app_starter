import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_starter/bloc/search/search_event.dart';
import 'package:mobile_app_starter/bloc/search/search_state.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';
import 'package:stream_transform/stream_transform.dart';

/// How long typing must pause before a search actually runs.
const Duration kSearchDebounce = Duration(milliseconds: 350);

/// Debounces queries, lets clears through immediately, and runs only the
/// newest event.
///
/// **Every** event feeds the debounce timer, including clears — that is what
/// evicts a query still waiting in the window, since debounce keeps only the
/// last event it saw. Only queries come *out* of that branch; clears are taken
/// undebounced so the reset is instant. See ARCHITECTURE.md, "The search
/// transformer".
EventTransformer<SearchEvent> _searchTransformer(Duration duration) {
  return (Stream<SearchEvent> events, EventMapper<SearchEvent> mapper) {
    final Stream<SearchEvent> debouncedQueries = events
        .debounce(duration)
        .whereType<SearchQueryChanged>();
    final Stream<SearchEvent> immediateClears = events
        .whereType<SearchCleared>();
    return restartable<SearchEvent>()(
      debouncedQueries.merge(immediateClears),
      mapper,
    );
  };
}

/// One `on<SearchEvent>` handler, not one per event type: separate
/// registrations get separate transformed streams, so a clear could neither
/// cancel a running query nor evict one waiting in the debounce window.
///
/// No [SafeEmit] here, unlike the cubits: a `Bloc` handler is handed an
/// [Emitter] and must use that one, and it already no-ops once the handler is
/// cancelled or the bloc closes.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository) : super(const SearchIdle()) {
    on<SearchEvent>(
      _onSearchEvent,
      transformer: _searchTransformer(kSearchDebounce),
    );
  }

  final PokemonRepository _repository;

  /// [restartable] cancels the superseded *handler*, not the HTTP requests it
  /// started; cancelling this token is what actually stops the transport.
  CancelToken? _requestToken;

  Future<void> _onSearchEvent(
    SearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    _requestToken?.cancel();
    switch (event) {
      case SearchCleared():
        emit(const SearchIdle());
      case SearchQueryChanged(:final String query):
        await _onQueryChanged(query.trim(), emit);
    }
  }

  Future<void> _onQueryChanged(String query, Emitter<SearchState> emit) async {
    if (query.isEmpty) {
      emit(const SearchIdle());
      return;
    }

    emit(const SearchLoading());
    final CancelToken token = CancelToken();
    _requestToken = token;

    try {
      final List<Pokemon> results = await _repository.searchByName(
        query,
        cancelToken: token,
      );
      emit(
        results.isEmpty
            ? SearchEmpty(query)
            : SearchSuccess(results, query: query),
      );
    } on RequestCancelledException {
      // Superseded by a newer query or a clear; the newer handler owns the
      // state now.
    } on AppException catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(SearchFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      // No message: the widget layer localizes the generic fallback.
      emit(const SearchFailure());
    }
  }

  @override
  Future<void> close() {
    _requestToken?.cancel();
    return super.close();
  }
}
