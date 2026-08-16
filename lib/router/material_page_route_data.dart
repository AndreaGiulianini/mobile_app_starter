import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Makes a typed route build a [MaterialPage].
///
/// Mandatory on every route: without it go_router silently falls back to
/// `NoTransitionPage` and the app loses all page transitions. See
/// ARCHITECTURE.md, "Routing".
mixin MaterialPageRouteData on GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(
        key: state.pageKey,
        name: state.name ?? state.path,
        child: build(context, state),
      );
}
