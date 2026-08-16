import 'package:equatable/equatable.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Adds [id] if absent, removes it otherwise.
final class FavoriteToggled extends FavoritesEvent {
  const FavoriteToggled(this.id);

  final int id;

  @override
  List<Object?> get props => <Object?>[id];
}
