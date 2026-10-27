import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mirra/main.dart';
import 'package:mirra/router.dart';
import 'package:mirra/services/simulation_service.dart';
import 'package:mirra/state/providers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture Mirra screens', (tester) async {
    final c = ProviderContainer(overrides: [
      simulationServiceProvider.overrideWithValue(MockSimulationService(stepDelay: const Duration(milliseconds: 600))),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MirraApp()));
    await binding.convertFlutterSurfaceToImage();

    Future<void> settle([int ms = 900]) async {
      for (var i = 0; i < ms ~/ 100; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> shot(String name) async {
      await settle();
      await binding.takeScreenshot(name);
    }

    void go(String path) => c.read(routerProvider).go(path);
    void push(String path) => c.read(routerProvider).push(path);

    await settle(1500);
    await tester.tap(find.byKey(const Key('age')));
    await shot('01-welcome');

    await tester.tap(find.byKey(const Key('getStarted')));
    await shot('02-sign-up');

    c.read(onboardingProvider.notifier).signUp();
    push('/consent');
    await settle();
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(Key('consent$i')));
    }
    await shot('03-consent');

    c.read(onboardingProvider.notifier).giveConsent();
    go('/studio');
    await shot('04-studio');

    await tester.tap(find.byKey(const Key('tile-filler')));
    await shot('05-photo');

    push('/filler');
    await shot('06-filler-botox');

    push('/generating');
    await settle(1200);
    await binding.takeScreenshot('07-generating');
    await settle(3500);
    await shot('08-result');

    go('/studio');
    await settle();
    await tester.tap(find.byKey(const Key('tile-hair')));
    await settle();
    push('/hair');
    await shot('09-hairstyle');

    go('/history');
    await shot('10-history');

    go('/clinic');
    await shot('11-clinic');

    push('/clinic/client');
    await shot('12-clinic-client');

    c.read(clockOffsetProvider.notifier).advance(const Duration(days: 2));
    go('/studio');
    push('/paywall');
    await shot('13-paywall');

    await c.read(subscriptionProvider.notifier).purchase();
    go('/account');
    await settle();
    push('/subscription');
    await shot('14-subscription');

    go('/account');
    await settle();
    push('/privacy');
    await shot('15-privacy');

    c.read(localeProvider.notifier).set(const Locale('he'));
    go('/studio');
    await shot('16-studio-hebrew');
  });
}
