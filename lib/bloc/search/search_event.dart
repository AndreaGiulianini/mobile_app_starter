import 'package:equatable/equatable.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Emitted on every keystroke; the bloc debounces.
final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class SearchCleared extends SearchEvent {
  const SearchCleared();
}
