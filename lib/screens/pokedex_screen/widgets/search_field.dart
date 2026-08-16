import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/bloc/search/search_bloc.dart';
import 'package:mobile_app_starter/bloc/search/search_event.dart';
import 'package:mobile_app_starter/bloc/search/search_state.dart';
import 'package:mobile_app_starter/l10n/app_localizations.dart';

/// Search box in the app bar.
///
/// Fires one event per keystroke and nothing else — debouncing is the bloc's
/// job, not the widget's.
class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    // The field sits inside the AppBar, whose background differs per mode
    // (primary in light, surface in dark); follow its foreground rather than
    // assuming onPrimary.
    final Color foreground =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    return TextField(
      controller: _controller,
      // An emptied field resets immediately: an empty query has nothing to
      // debounce, and the clear-button path already resets instantly.
      onChanged: (String value) => context.read<SearchBloc>().add(
        value.trim().isEmpty
            ? const SearchCleared()
            : SearchQueryChanged(value),
      ),
      textInputAction: TextInputAction.search,
      style: TextStyle(color: foreground),
      decoration: InputDecoration(
        hintText: l10n.searchHint,
        hintStyle: TextStyle(color: foreground.withValues(alpha: 0.7)),
        border: InputBorder.none,
        filled: false,
        prefixIcon: Icon(Icons.search, color: foreground),
        suffixIcon: BlocSelector<SearchBloc, SearchState, bool>(
          selector: (SearchState state) => state is! SearchIdle,
          builder: (BuildContext context, bool hasQuery) {
            if (!hasQuery) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: Icon(Icons.clear, color: foreground),
              onPressed: () {
                _controller.clear();
                context.read<SearchBloc>().add(const SearchCleared());
              },
            );
          },
        ),
      ),
    );
  }
}
