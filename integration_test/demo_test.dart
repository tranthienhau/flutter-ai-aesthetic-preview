import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mirra/main.dart';
import 'package:mirra/router.dart';
import 'package:mirra/services/simulation_service.dart';
import 'package:mirra/state/providers.dart';

/// Paced walkthrough used to record the README demo GIFs.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo walkthrough', (tester) async {
    final c = ProviderContainer(overrides: [
      simulationServiceProvider.overrideWithValue(MockSimulationService(stepDelay: const Duration(milliseconds: 650))),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MirraApp()));

    Future<void> wait(int ms) async {
      for (var i = 0; i < ms ~/ 50; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    Future<void> tapKey(String key, {int after = 900}) async {
      final f = find.byKey(Key(key));
      await tester.scrollUntilVisible(f, 250, scrollable: find.byType(Scrollable).last);
      await wait(250);
      await tester.tap(f);
      await wait(after);
    }

    await wait(3000);
    await tester.tap(find.byKey(const Key('age')));
    await wait(700);
    await tapKey('getStarted', after: 1000);
    await tapKey('startTrial', after: 1000);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(Key('consent$i')));
      await wait(250);
    }
    await tapKey('agree', after: 1600);

    await tapKey('tile-filler', after: 1200);
    await tapKey('usePhoto', after: 1200);
    // Raise lip filler volume on the slider.
    final slider = find.byType(Slider);
    await tester.scrollUntilVisible(slider, 200, scrollable: find.byType(Scrollable).last);
    await tester.drag(slider, const Offset(40, 0));
    await wait(900);
    await tapKey('generate', after: 4200);

    // Drag the before/after handle.
    final cmp = find.byKey(const Key('compare-slider'));
    final box = tester.getRect(cmp);
    final g = await tester.startGesture(box.center);
    for (var i = 0; i < 14; i++) {
      await g.moveBy(const Offset(-10, 0));
      await wait(50);
    }
    for (var i = 0; i < 26; i++) {
      await g.moveBy(const Offset(10, 0));
      await wait(50);
    }
    await g.up();
    await wait(1200);

    c.read(routerProvider).go('/history');
    await wait(1600);
    c.read(routerProvider).go('/clinic');
    await wait(1600);
    await tester.tap(find.byKey(const Key('session-Noa Levi')));
    await wait(2000);
  });
}
