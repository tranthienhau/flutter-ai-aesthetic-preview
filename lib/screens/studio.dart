import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../billing/subscription.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme.dart';
import '../widgets/common.dart';

class StudioScreen extends ConsumerWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final sub = ref.watch(subscriptionProvider);
    final now = ref.watch(nowProvider);
    final previews = ref.watch(previewsProvider);
    final chip = switch (sub.status) {
      SubStatus.trial => Tag(s.t('studio.trial').replaceAll('{n}', '${sub.trialDaysLeft(now)}')),
      SubStatus.active => Tag(s.t('studio.active'), icon: Icons.verified_outlined),
      SubStatus.expired => Tag(s.t('sub.expired'), fg: C.warning, bg: C.warningTint),
      _ => const SizedBox.shrink(),
    };

    void start(SimulationType t) {
      ref.read(draftProvider.notifier).set(SimulationRequest(type: t, photoAsset: 'assets/sim/before.jpg'));
      context.push('/photo');
    }

    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      ScreenHeader(s.t('studio.hi'), below: chip),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(R.card),
          child: SizedBox(
            height: 300,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/images/hero-hair.jpg', fit: BoxFit.cover, alignment: const Alignment(0, -0.6)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.25, 1],
                    colors: [Color(0x000C1F18), Color(0xE60C1F18)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(s.t('studio.new'), style: T.display.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(s.t('studio.newSub'), style: const TextStyle(color: Colors.white, fontSize: 15)),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('heroUpload'),
                      onPressed: () => start(SimulationType.filler),
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.white, foregroundColor: C.text, shape: const StadiumBorder()),
                      icon: const Icon(Icons.photo_camera_outlined, color: C.accentFill),
                      label: Text(s.t('studio.upload'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SectionTitle(s.t('studio.try')),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          for (final (t, img, key) in [
            (SimulationType.hair, 'assets/images/tile-hair.jpg', 'type.hair'),
            (SimulationType.makeup, 'assets/images/tile-makeup.jpg', 'type.makeup'),
            (SimulationType.filler, 'assets/images/tile-filler.jpg', 'type.filler'),
          ])
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: InkWell(
                  key: Key('tile-${t.name}'),
                  borderRadius: BorderRadius.circular(R.card),
                  onTap: () => start(t),
                  child: AppCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(children: [
                      PhotoBox(img, radius: 14, height: 110, width: double.infinity),
                      const SizedBox(height: 8),
                      Text(s.t(key),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SectionTitle(s.t('studio.recent')),
      ),
      SizedBox(
        height: 190,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: previews.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final p = previews[i];
            return InkWell(
              onTap: () => context.push('/result/${p.id}'),
              child: SizedBox(
                width: 140,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(fit: StackFit.expand, children: [
                        previewAfter(p),
                        const Positioned(left: 6, bottom: 6, child: AiBadge(small: true)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(p.request.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.label),
                  Text(shortDate(p.createdAt), style: T.caption),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class PhotoScreen extends ConsumerWidget {
  const PhotoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final draft = ref.watch(draftProvider);
    final next = switch (draft.type) {
      SimulationType.hair => '/hair',
      SimulationType.makeup => '/makeup',
      SimulationType.filler => '/filler',
    };
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: Text(s.t('photo.title')),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            height: 420,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset(draft.photoAsset, fit: BoxFit.cover, alignment: const Alignment(0, -0.4)),
              Center(
                child: Container(
                  width: 210,
                  height: 280,
                  margin: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    border: Border.all(color: C.accent, width: 3),
                    borderRadius: const BorderRadius.all(Radius.elliptical(105, 140)),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final k in ['photo.centered', 'photo.light', 'photo.noFilter'])
            Tag(s.t(k), icon: Icons.check_circle_outline, fg: C.success, bg: C.successTint),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: SecondaryButton(s.t('photo.retake'), icon: Icons.photo_camera_outlined, onPressed: () {})),
          const SizedBox(width: 10),
          Expanded(child: SecondaryButton(s.t('photo.gallery'), icon: Icons.photo_library_outlined, onPressed: () {})),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.lock_outline, size: 16, color: C.text2),
          const SizedBox(width: 6),
          Flexible(child: Text(s.t('photo.secure'), style: T.caption)),
        ]),
        const SizedBox(height: 16),
        PrimaryButton(s.t('photo.use'), key: const Key('usePhoto'), onPressed: () => context.push(next)),
      ]),
    );
  }
}

/// Gate before generation: consent first, then entitlement (trial or paid).
void goGenerate(BuildContext context, WidgetRef ref) {
  final ob = ref.read(onboardingProvider);
  final sub = ref.read(subscriptionProvider);
  final now = ref.read(nowProvider);
  if (!ob.consentGiven) {
    context.push('/consent');
    return;
  }
  final draft = ref.read(draftProvider);
  final allowed = draft.type == SimulationType.filler ? sub.canGenerateFiller(now) : sub.hasAccess(now);
  if (!allowed) {
    context.push('/paywall');
    return;
  }
  context.push('/generating');
}

class HairScreen extends ConsumerStatefulWidget {
  const HairScreen({super.key});
  @override
  ConsumerState<HairScreen> createState() => _HairScreenState();
}

class _HairScreenState extends ConsumerState<HairScreen> {
  String _style = 'Sleek ponytail';
  String _color = 'Copper';

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('type.hair')),
        actions: const [Padding(padding: EdgeInsets.only(right: 16, left: 16), child: Avatar('assets/sim/before.jpg', size: 34))],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        Text(s.t('hair.style'), style: T.title),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: [
            for (final (name, img) in hairStyles)
              InkWell(
                onTap: () => setState(() => _style = name),
                child: AppCard(
                  padding: const EdgeInsets.all(6),
                  border: _style == name ? C.accentFill : null,
                  child: Column(children: [
                    Expanded(
                      child: Stack(fit: StackFit.expand, children: [
                        PhotoBox(img, radius: 14, alignment: const Alignment(0, -0.5)),
                        if (_style == name)
                          const Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(radius: 13, backgroundColor: C.accentFill, child: Icon(Icons.check, size: 16, color: Colors.white)),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    Text(name, style: T.label.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                  ]),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(s.t('hair.color'), style: T.title),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (name, hex) in hairColors)
            MirraChip(name, selected: _color == name, dot: Color(hex), onTap: () => setState(() => _color = name)),
        ]),
        const SizedBox(height: 24),
        PrimaryButton(s.t('generate'), key: const Key('generate'), icon: Icons.auto_awesome_outlined, onPressed: () {
          ref.read(draftProvider.notifier).set(SimulationRequest(
              type: SimulationType.hair, photoAsset: 'assets/sim/before.jpg', hairStyle: _style, hairColor: _color));
          goGenerate(context, ref);
        }),
        const SizedBox(height: 10),
        Text(s.t('hair.credit'), textAlign: TextAlign.center, style: T.caption),
      ]),
    );
  }
}

class MakeupScreen extends ConsumerStatefulWidget {
  const MakeupScreen({super.key});
  @override
  ConsumerState<MakeupScreen> createState() => _MakeupScreenState();
}

class _MakeupScreenState extends ConsumerState<MakeupScreen> {
  String _look = 'Soft glam';
  double _intensity = 0.6;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('type.makeup'))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: makeupLooks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final (name, img) = makeupLooks[i];
              return InkWell(
                onTap: () => setState(() => _look = name),
                child: SizedBox(
                  width: 140,
                  child: AppCard(
                    padding: const EdgeInsets.all(6),
                    border: _look == name ? C.accentFill : null,
                    child: Column(children: [
                      Expanded(child: PhotoBox(img, radius: 14, width: double.infinity)),
                      const SizedBox(height: 6),
                      Text(name, style: T.label.copyWith(fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(s.t('makeup.intensity'), style: T.title)),
              Text('${(_intensity * 100).round()}%', style: T.h1.copyWith(color: C.accentFill)),
            ]),
            Slider(value: _intensity, onChanged: (v) => setState(() => _intensity = v)),
          ]),
        ),
        const SizedBox(height: 24),
        PrimaryButton(s.t('generate'), key: const Key('generate'), icon: Icons.auto_awesome_outlined, onPressed: () {
          ref.read(draftProvider.notifier).set(
              SimulationRequest(type: SimulationType.makeup, photoAsset: 'assets/sim/before.jpg', makeupLook: _look));
          goGenerate(context, ref);
        }),
      ]),
    );
  }
}

class FillerScreen extends ConsumerStatefulWidget {
  const FillerScreen({super.key});
  @override
  ConsumerState<FillerScreen> createState() => _FillerScreenState();
}

class _FillerScreenState extends ConsumerState<FillerScreen> {
  TreatmentArea _area = TreatmentArea.lips;
  double _amount = 1.0;
  bool _natural = true;

  static const _markers = {
    TreatmentArea.forehead: Offset(0.5, 0.26),
    TreatmentArea.underEye: Offset(0.36, 0.43),
    TreatmentArea.cheeks: Offset(0.68, 0.52),
    TreatmentArea.lips: Offset(0.5, 0.66),
    TreatmentArea.jawline: Offset(0.3, 0.72),
  };

  static const _chipName = {
    TreatmentArea.lips: 'Lips',
    TreatmentArea.cheeks: 'Cheeks',
    TreatmentArea.jawline: 'Jawline',
    TreatmentArea.forehead: 'Forehead lines',
    TreatmentArea.underEye: 'Under-eye',
  };

  void _pick(TreatmentArea a) => setState(() {
        _area = a;
        _amount = a.defaultAmount;
      });

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final amountLabel = _area.isBotox ? '${_amount.round()} units' : '${_amount.toStringAsFixed(1)} ml';
    return Scaffold(
      appBar: AppBar(title: Text(s.t('type.filler'))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(R.card),
          child: SizedBox(
            height: 330,
            child: LayoutBuilder(builder: (context, c) {
              return Stack(fit: StackFit.expand, children: [
                Image.asset('assets/sim/before.jpg', fit: BoxFit.cover, alignment: const Alignment(0, -0.45)),
                for (final e in _markers.entries)
                  Positioned(
                    left: c.maxWidth * e.value.dx - 16,
                    top: c.maxHeight * e.value.dy - 16,
                    child: GestureDetector(
                      onTap: () => _pick(e.key),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _area == e.key ? C.accentFill : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: cardShadow,
                        ),
                        child: Text('${e.key.index + 1}',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: _area == e.key ? Colors.white : C.text)),
                      ),
                    ),
                  ),
              ]);
            }),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final a in TreatmentArea.values)
            MirraChip(_chipName[a]!, selected: _area == a, onTap: () => _pick(a)),
        ]),
        const SizedBox(height: 16),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text('${areaName(_area)} ${_area.isBotox ? 'Botox' : 'filler'}', style: T.title)),
              Text(amountLabel, key: const Key('amount'), style: T.display.copyWith(color: C.accentFill, fontSize: 30)),
            ]),
            const SizedBox(height: 4),
            Text(s.t('filler.volume'), style: T.caption),
            Slider(
              value: _amount,
              min: _area.min,
              max: _area.max,
              divisions: ((_area.max - _area.min) / _area.step).round(),
              onChanged: (v) => setState(() => _amount = v),
            ),
            Row(children: [
              Text(_area.isBotox ? '${_area.min.round()} units' : '${_area.min} ml', style: T.caption),
              const Spacer(),
              Text(_area.isBotox ? '${_area.max.round()} units' : '${_area.max} ml', style: T.caption),
            ]),
            const Divider(height: 24, color: C.border),
            Row(children: [
              Expanded(child: Text(s.t('filler.natural'), style: T.label)),
              Switch(value: _natural, onChanged: (v) => setState(() => _natural = v)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline, size: 18, color: C.text2),
          const SizedBox(width: 8),
          Expanded(child: Text(s.t('filler.info'), style: const TextStyle(fontSize: 14, color: C.text2))),
        ]),
        const SizedBox(height: 20),
        PrimaryButton(s.t('generate'), key: const Key('generate'), icon: Icons.auto_awesome_outlined, onPressed: () {
          ref.read(draftProvider.notifier).set(SimulationRequest(
              type: SimulationType.filler,
              photoAsset: 'assets/sim/before.jpg',
              area: _area,
              amount: _amount,
              naturalLook: _natural));
          goGenerate(context, ref);
        }),
      ]),
    );
  }
}
