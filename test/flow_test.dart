import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirra/main.dart';
import 'package:mirra/services/simulation_service.dart';
import 'package:mirra/state/providers.dart';

void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  await tester.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).last);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('age gate blocks sign up until confirmed', (tester) async {
    phone(tester);
    await tester.pumpWidget(const ProviderScope(child: MirraApp()));
    await tester.pumpAndSettle();
    final cta = tester.widget<FilledButton>(
        find.descendant(of: find.byKey(const Key('getStarted')), matching: find.byType(FilledButton)));
    expect(cta.onPressed, isNull);
    await tester.tap(find.byKey(const Key('age')));
    await tester.pumpAndSettle();
    final cta2 = tester.widget<FilledButton>(
        find.descendant(of: find.byKey(const Key('getStarted')), matching: find.byType(FilledButton)));
    expect(cta2.onPressed, isNotNull);
  });

  testWidgets('end to end: sign up, consent, filler preview with AI label and disclaimer', (tester) async {
    phone(tester);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        simulationServiceProvider.overrideWithValue(MockSimulationService(stepDelay: const Duration(milliseconds: 10))),
      ],
      child: const MirraApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('age')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('getStarted')));
    await tester.pumpAndSettle();
    await tapKey(tester, 'startTrial');

    // Consent: button disabled until all four boxes are ticked.
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(Key('consent$i')));
    }
    await tester.pumpAndSettle();
    await tapKey(tester, 'agree');
    expect(find.text('Trial - 3 days left'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tile-filler')));
    await tester.pumpAndSettle();
    await tapKey(tester, 'usePhoto');
    await tester.scrollUntilVisible(find.byKey(const Key('generate')), 300,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('generate')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Your preview'), findsOneWidget);
    expect(find.text('AI simulation'), findsWidgets);
    expect(find.textContaining('not a guaranteed medical outcome'), findsOneWidget);
  });
}
