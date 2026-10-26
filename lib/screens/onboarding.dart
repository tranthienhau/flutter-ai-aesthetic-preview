import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../theme.dart';
import '../widgets/common.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final ob = ref.watch(onboardingProvider);
    final he = ref.watch(localeProvider).languageCode == 'he';
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            child: Image.asset('assets/images/welcome-hero.jpg',
                height: 400, fit: BoxFit.cover, alignment: const Alignment(0, -0.2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Image.asset('assets/brand/mark.png', width: 36, height: 36),
                const SizedBox(width: 6),
                const Text('Mirra', style: TextStyle(fontFamily: 'Spectral', fontSize: 22, fontWeight: FontWeight.w600, color: C.accentFill)),
              ]),
              const SizedBox(height: 12),
              Text(s.t('welcome.title'), style: T.display),
              const SizedBox(height: 8),
              Text(s.t('welcome.sub'), style: T.body.copyWith(color: C.text2)),
              const SizedBox(height: 20),
              SegmentedButton<String>(
                key: const Key('lang'),
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: C.accentFill,
                  selectedForegroundColor: Colors.white,
                  foregroundColor: C.text2,
                  side: const BorderSide(color: C.border),
                ),
                segments: const [
                  ButtonSegment(value: 'en', label: Text('English')),
                  ButtonSegment(value: 'he', label: Text('עברית')),
                ],
                selected: {he ? 'he' : 'en'},
                onSelectionChanged: (v) => ref.read(localeProvider.notifier).set(Locale(v.first)),
              ),
              const SizedBox(height: 12),
              InkWell(
                key: const Key('age'),
                onTap: () => ref.read(onboardingProvider.notifier).confirmAge(!ob.ageConfirmed),
                child: Row(children: [
                  Checkbox(
                      value: ob.ageConfirmed,
                      onChanged: (v) => ref.read(onboardingProvider.notifier).confirmAge(v ?? false)),
                  Expanded(child: Text(s.t('welcome.age'), style: T.label)),
                ]),
              ),
              const SizedBox(height: 16),
              PrimaryButton(s.t('welcome.cta'),
                  key: const Key('getStarted'), onPressed: ob.ageConfirmed ? () => context.push('/signup') : null),
              const SizedBox(height: 14),
              Center(child: Text(s.t('welcome.signin'), style: T.label.copyWith(color: C.accentFill))),
            ]),
          ),
        ]),
      ),
    );
  }
}

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('signup.title'))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(gradient: C.heroGradient, borderRadius: BorderRadius.circular(R.card)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.t('signup.trial'),
                style: T.display.copyWith(color: Colors.white, fontSize: 36)),
            const SizedBox(height: 6),
            Text(s.t('signup.trialSub'), style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
          ]),
        ),
        const SizedBox(height: 20),
        TextFormField(initialValue: 'Noa Levi', decoration: InputDecoration(labelText: s.t('signup.name'))),
        const SizedBox(height: 12),
        TextFormField(initialValue: 'noa.levi@gmail.com', decoration: InputDecoration(labelText: s.t('signup.email'))),
        const SizedBox(height: 12),
        TextFormField(
            initialValue: 'mirra-demo-2026',
            obscureText: true,
            decoration: InputDecoration(labelText: s.t('signup.password'))),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () {},
            style: FilledButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
            icon: const Icon(Icons.apple, color: Colors.white),
            label: Text(s.t('signup.apple'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: C.border), shape: const StadiumBorder(), foregroundColor: C.text),
            icon: const Text('G', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF4285F4), fontSize: 18)),
            label: Text(s.t('signup.google'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(s.t('signup.cta'), key: const Key('startTrial'), onPressed: () {
          ref.read(onboardingProvider.notifier).signUp();
          context.push('/consent');
        }),
        const SizedBox(height: 12),
        Text(s.t('signup.note'), textAlign: TextAlign.center, style: T.caption),
      ]),
    );
  }
}

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});
  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  final _checked = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final all = _checked.every((c) => c);
    return Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 32), children: [
        Text(s.t('consent.title'), style: T.display),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: C.warningTint, borderRadius: BorderRadius.circular(R.card)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, color: C.warning),
            const SizedBox(width: 10),
            Expanded(
                child: Text(s.t('consent.disclaimer'),
                    style: const TextStyle(fontSize: 15, color: C.text, height: 1.45, fontWeight: FontWeight.w500))),
          ]),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: InkWell(
                key: Key('consent$i'),
                onTap: () => setState(() => _checked[i] = !_checked[i]),
                child: Row(children: [
                  Checkbox(value: _checked[i], onChanged: (v) => setState(() => _checked[i] = v ?? false)),
                  Expanded(child: Text(s.t('consent.${i + 1}'), style: const TextStyle(fontSize: 14, height: 1.4))),
                ]),
              ),
            ),
          ),
        const SizedBox(height: 4),
        Center(child: Text(s.t('consent.policy'), style: T.label.copyWith(color: C.accentFill))),
        const SizedBox(height: 20),
        PrimaryButton(s.t('consent.cta'), key: const Key('agree'), onPressed: all
            ? () {
                ref.read(onboardingProvider.notifier).giveConsent();
                context.go('/studio');
              }
            : null),
      ]),
    );
  }
}
