import 'package:equatable/equatable.dart';

/// The set of favourited Pokédex ids. Restored from storage before first build,
/// so there is no loading or error phase to model.
final class FavoritesState extends Equatable {
  const FavoritesState({this.ids = const <int>{}});

  final Set<int> ids;

  bool contains(int id) => ids.contains(id);

  int get count => ids.length;

  @override
  List<Object?> get props => <Object?>[ids];
}
