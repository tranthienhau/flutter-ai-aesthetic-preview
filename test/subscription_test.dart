import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirra/billing/billing_service.dart';
import 'package:mirra/billing/subscription.dart';
import 'package:mirra/state/providers.dart';

void main() {
  final t0 = DateTime(2026, 10, 27, 10);

  group('Subscription rules', () {
    test('sign up starts a 3-day trial with full access', () {
      final s = const Subscription().startTrial(t0);
      expect(s.status, SubStatus.trial);
      expect(s.trialEndsAt, t0.add(const Duration(days: 3)));
      expect(s.hasAccess(t0), isTrue);
      expect(s.trialDaysLeft(t0), 3);
      expect(s.trialDaysLeft(t0.add(const Duration(days: 2, hours: 1))), 1);
    });

    test('trial cannot be restarted', () {
      final s = const Subscription().startTrial(t0);
      final again = s.startTrial(t0.add(const Duration(days: 10)));
      expect(again.trialEndsAt, s.trialEndsAt);
    });

    test('trial expires after 3 days and shows the paywall', () {
      final s = const Subscription().startTrial(t0).tick(t0.add(const Duration(days: 3)));
      expect(s.status, SubStatus.expired);
      expect(s.hasAccess(t0.add(const Duration(days: 3))), isFalse);
      expect(s.showPaywall, isTrue);
    });

    test('subscribing during the trial bills from the trial end, not today', () {
      final s = const Subscription().startTrial(t0).purchase(t0.add(const Duration(days: 1)));
      expect(s.status, SubStatus.active);
      expect(s.autoRenew, isTrue);
      expect(s.periodEndsAt, t0.add(const Duration(days: 3 + Plan.periodDays)));
    });

    test('subscribing after expiry starts the period now', () {
      final later = t0.add(const Duration(days: 5));
      final s = const Subscription().startTrial(t0).tick(later).purchase(later);
      expect(s.periodEndsAt, later.add(const Duration(days: Plan.periodDays)));
      expect(s.hasAccess(later), isTrue);
    });

    test('active plan auto-renews each period', () {
      final s = const Subscription().startTrial(t0).purchase(t0);
      final end = s.periodEndsAt!;
      final renewed = s.tick(end.add(const Duration(hours: 1)));
      expect(renewed.status, SubStatus.active);
      expect(renewed.periodEndsAt, end.add(const Duration(days: Plan.periodDays)));
    });

    test('cancel keeps access until period end, then expires with no renewal', () {
      final s = const Subscription().startTrial(t0).purchase(t0).cancel();
      final end = s.periodEndsAt!;
      expect(s.status, SubStatus.cancelled);
      expect(s.autoRenew, isFalse);
      expect(s.hasAccess(end.subtract(const Duration(minutes: 1))), isTrue);
      final after = s.tick(end);
      expect(after.status, SubStatus.expired);
      expect(after.periodEndsAt, end);
    });

    test('cancel is a no-op outside an active plan', () {
      final s = const Subscription().startTrial(t0);
      expect(s.cancel().status, SubStatus.trial);
    });

    test('filler previews are capped per paid month and reset on renewal', () {
      var s = const Subscription().startTrial(t0).purchase(t0);
      final now = t0.add(const Duration(days: 4));
      for (var i = 0; i < Plan.fillerPreviewsPerMonth; i++) {
        s = s.useFiller();
      }
      expect(s.canGenerateFiller(now), isFalse);
      final renewed = s.tick(s.periodEndsAt!);
      expect(renewed.fillerUsed, 0);
      expect(renewed.canGenerateFiller(s.periodEndsAt!), isTrue);
    });
  });

  group('SubscriptionCtl with billing service', () {
    ProviderContainer make(BillingService billing) {
      final c = ProviderContainer(overrides: [billingServiceProvider.overrideWithValue(billing)]);
      addTearDown(c.dispose);
      return c;
    }

    test('sign up -> trial -> clock past trial -> paywall -> purchase -> access', () async {
      final billing = MockBillingService();
      final c = make(billing);
      c.read(onboardingProvider.notifier).signUp();
      expect(c.read(subscriptionProvider).status, SubStatus.trial);

      c.read(clockOffsetProvider.notifier).advance(const Duration(days: 3));
      expect(c.read(subscriptionProvider).status, SubStatus.expired);

      final ok = await c.read(subscriptionProvider.notifier).purchase();
      expect(ok, isTrue);
      expect(billing.purchases, 1);
      final sub = c.read(subscriptionProvider);
      expect(sub.status, SubStatus.active);
      expect(sub.hasAccess(c.read(nowProvider)), isTrue);
    });

    test('failed store purchase leaves the user on the paywall', () async {
      final c = make(MockBillingService(succeed: false));
      c.read(onboardingProvider.notifier).signUp();
      c.read(clockOffsetProvider.notifier).advance(const Duration(days: 4));
      final ok = await c.read(subscriptionProvider.notifier).purchase();
      expect(ok, isFalse);
      expect(c.read(subscriptionProvider).status, SubStatus.expired);
    });

    test('cancel flow keeps access then expires', () async {
      final c = make(MockBillingService());
      c.read(onboardingProvider.notifier).signUp();
      await c.read(subscriptionProvider.notifier).purchase();
      await c.read(subscriptionProvider.notifier).cancel();
      expect(c.read(subscriptionProvider).status, SubStatus.cancelled);
      c.read(clockOffsetProvider.notifier).advance(const Duration(days: 34));
      expect(c.read(subscriptionProvider).status, SubStatus.expired);
    });
  });
}
