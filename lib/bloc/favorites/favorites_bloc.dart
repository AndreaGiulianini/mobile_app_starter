import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_event.dart';
import 'package:mobile_app_starter/bloc/favorites/favorites_state.dart';

/// Favourited Pokédex ids, persisted across restarts by [HydratedBloc] — hence
/// no load step and no loading state.
class FavoritesBloc extends HydratedBloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(const FavoritesState()) {
    on<FavoriteToggled>(_onToggled);
  }

  void _onToggled(FavoriteToggled event, Emitter<FavoritesState> emit) {
    final Set<int> next = Set<int>.of(state.ids);
    if (!next.remove(event.id)) {
      next.add(event.id);
    }
    // Unmodifiable: an in-place mutation of exposed state would keep
    // Equatable equality and silently skip the rebuild.
    emit(FavoritesState(ids: Set<int>.unmodifiable(next)));
  }

  /// Bumped when the persisted shape changes, so [fromJson] has something to
  /// branch on when migrating old payloads.
  static const int _schemaVersion = 1;

  @override
  FavoritesState? fromJson(Map<String, dynamic> json) {
    final Object? version = json['v'];
    // Version 1 and the unversioned legacy payload share a shape; anything
    // newer is unknown and must not be parsed as if it were.
    if (version != null && version != _schemaVersion) {
      return null;
    }
    final Object? ids = json['ids'];
    if (ids is! List) {
      return null;
    }
    // A JSON round-trip can widen ints to doubles (on web it always does);
    // filtering on `int` alone would silently erase every favourite.
    return FavoritesState(
      ids: Set<int>.unmodifiable(
        ids.whereType<num>().map((num id) => id.toInt()),
      ),
    );
  }

  @override
  Map<String, dynamic>? toJson(FavoritesState state) {
    return <String, dynamic>{'v': _schemaVersion, 'ids': state.ids.toList()};
  }
}
