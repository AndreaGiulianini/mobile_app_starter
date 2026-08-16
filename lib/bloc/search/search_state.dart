import 'package:equatable/equatable.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => <Object?>[];
}

/// No query typed yet — the screen shows the normal paginated list.
final class SearchIdle extends SearchState {
  const SearchIdle();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchSuccess extends SearchState {
  const SearchSuccess(this.results, {required this.query});

  final List<Pokemon> results;
  final String query;

  @override
  List<Object?> get props => <Object?>[results, query];
}

/// Distinct from an empty [SearchSuccess] so the UI can say "no results for X".
final class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class SearchFailure extends SearchState {
  const SearchFailure([this.message]);

  /// Null when there is no server-provided text; the UI falls back to the
  /// localized `searchFailed` string. Blocs have no BuildContext, so the
  /// lookup belongs to the widget layer.
  final String? message;

  @override
  List<Object?> get props => <Object?>[message];
}
