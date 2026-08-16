import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_app_starter/widgets/app_state_views.dart';

import '../helpers/pump_app.dart';

void main() {
  group('AppLoadingView', () {
    testWidgets('shows a spinner, and a caption only when given one', (
      WidgetTester tester,
    ) async {
      await tester.pumpApp(const Scaffold(body: AppLoadingView()));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);

      await tester.pumpApp(
        const Scaffold(body: AppLoadingView(message: 'Loading…')),
      );
      await tester.pump();
      expect(find.text('Loading…'), findsOneWidget);
    });
  });

  group('AppErrorView', () {
    testWidgets('the plain constructor offers no retry', (
      WidgetTester tester,
    ) async {
      await tester.pumpApp(const Scaffold(body: AppErrorView(message: 'Boom')));
      await tester.pump();

      expect(find.text('Boom'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('withRetry wires the button to the callback', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpApp(
        Scaffold(
          body: AppErrorView.withRetry(
            message: 'Offline',
            retryLabel: 'Retry',
            onRetry: () => taps++,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      expect(taps, 1);
    });
  });

  group('AppEmptyView', () {
    testWidgets('shows the message and a default icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpApp(
        const Scaffold(body: AppEmptyView(message: 'Nothing here')),
      );
      await tester.pump();

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('accepts an icon override', (WidgetTester tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: AppEmptyView(message: 'None', icon: Icons.inbox),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });
  });
}
