import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../billing/billing_service.dart';
import '../billing/subscription.dart';
import '../data/mock_data.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/simulation_service.dart';

const _geminiKey = String.fromEnvironment('GEMINI_API_KEY');

// ---------- clock (demo "time travel" for trial expiry) ----------
class ClockOffset extends Notifier<Duration> {
  @override
  Duration build() => Duration.zero;
  void advance(Duration d) {
    state += d;
    ref.read(subscriptionProvider.notifier).sync();
  }
}

final clockOffsetProvider = NotifierProvider<ClockOffset, Duration>(ClockOffset.new);
final nowProvider = Provider<DateTime>((ref) => DateTime(2026, 10, 27, 10).add(ref.watch(clockOffsetProvider)));

// ---------- locale ----------
class LocaleCtl extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');
  void set(Locale l) => state = l;
}

final localeProvider = NotifierProvider<LocaleCtl, Locale>(LocaleCtl.new);
final stringsProvider = Provider<S>((ref) => S(ref.watch(localeProvider)));

// ---------- onboarding / compliance gates ----------
class Onboarding {
  const Onboarding({this.ageConfirmed = false, this.signedUp = false, this.consentGiven = false});
  final bool ageConfirmed;
  final bool signedUp;
  final bool consentGiven;
  Onboarding copyWith({bool? ageConfirmed, bool? signedUp, bool? consentGiven}) => Onboarding(
        ageConfirmed: ageConfirmed ?? this.ageConfirmed,
        signedUp: signedUp ?? this.signedUp,
        consentGiven: consentGiven ?? this.consentGiven,
      );
}

class OnboardingCtl extends Notifier<Onboarding> {
  @override
  Onboarding build() => const Onboarding();
  void confirmAge(bool v) => state = state.copyWith(ageConfirmed: v);
  void signUp() {
    state = state.copyWith(signedUp: true);
    ref.read(subscriptionProvider.notifier).startTrial();
  }

  void giveConsent() => state = state.copyWith(consentGiven: true);
  void revokeConsent() => state = state.copyWith(consentGiven: false);
}

final onboardingProvider = NotifierProvider<OnboardingCtl, Onboarding>(OnboardingCtl.new);

// ---------- services ----------
final billingServiceProvider = Provider<BillingService>((ref) => MockBillingService());
final simulationServiceProvider = Provider<SimulationService>(
  (ref) => _geminiKey.isEmpty ? MockSimulationService() : GeminiSimulationService(_geminiKey),
);

// ---------- subscription ----------
class SubscriptionCtl extends Notifier<Subscription> {
  @override
  Subscription build() => const Subscription();

  DateTime get _now => ref.read(nowProvider);

  /// Apply trial expiry / renewal for the current time. In production this
  /// also runs on app resume and on store server notifications.
  void sync() => state = state.tick(_now);
  void startTrial() => state = state.startTrial(_now);

  Future<bool> purchase() async {
    final ok = await ref.read(billingServiceProvider).purchaseMonthly();
    if (ok) state = state.tick(_now).purchase(_now);
    return ok;
  }

  Future<void> cancel() async {
    await ref.read(billingServiceProvider).openManageSubscriptions();
    state = state.cancel();
  }

  void useFiller() => state = state.useFiller();
}

final subscriptionProvider = NotifierProvider<SubscriptionCtl, Subscription>(SubscriptionCtl.new);

// ---------- current draft request ----------
class DraftCtl extends Notifier<SimulationRequest> {
  @override
  SimulationRequest build() =>
      const SimulationRequest(type: SimulationType.filler, photoAsset: 'assets/sim/before.jpg');
  void set(SimulationRequest r) => state = r;
}

final draftProvider = NotifierProvider<DraftCtl, SimulationRequest>(DraftCtl.new);

// ---------- previews / history ----------
class PreviewsCtl extends Notifier<List<Preview>> {
  @override
  List<Preview> build() => seedPreviews();
  void add(Preview p) => state = [p, ...state];
  void delete(String id) => state = state.where((p) => p.id != id).toList();
  void deleteAll() => state = [];
  void share(String id) =>
      state = [for (final p in state) p.id == id ? p.copyWith(sharedWithClinic: true) : p];
}

final previewsProvider = NotifierProvider<PreviewsCtl, List<Preview>>(PreviewsCtl.new);

// ---------- generation ----------
class Generation {
  const Generation({this.step = 0, this.result, this.error});
  final int step;
  final Preview? result;
  final String? error;
}

class GenerationCtl extends Notifier<Generation> {
  @override
  Generation build() => const Generation();

  Future<Preview?> run() async {
    final req = ref.read(draftProvider);
    state = const Generation(step: 0);
    try {
      final r = await ref
          .read(simulationServiceProvider)
          .generate(req, onStep: (s) => state = Generation(step: s));
      final p = Preview(
        id: 'p${DateTime.now().microsecondsSinceEpoch}',
        request: req,
        beforeAsset: req.photoAsset,
        afterAsset: r.afterAsset,
        afterBytes: r.afterBytes,
        createdAt: ref.read(nowProvider),
      );
      if (req.type == SimulationType.filler) ref.read(subscriptionProvider.notifier).useFiller();
      ref.read(previewsProvider.notifier).add(p);
      state = Generation(step: 4, result: p);
      return p;
    } catch (e) {
      state = Generation(error: '$e');
      return null;
    }
  }
}

final generationProvider = NotifierProvider<GenerationCtl, Generation>(GenerationCtl.new);

// ---------- clinic ----------
final clinicSessionsProvider = Provider<List<ClinicSession>>((ref) => clinicSessions);

class ClinicShareCtl extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool v) => state = v;
}

final clinicShareProvider = NotifierProvider<ClinicShareCtl, bool>(ClinicShareCtl.new);
