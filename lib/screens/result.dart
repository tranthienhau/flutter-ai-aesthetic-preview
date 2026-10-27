import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme.dart';
import '../widgets/before_after.dart';
import '../widgets/common.dart';

class GeneratingScreen extends ConsumerStatefulWidget {
  const GeneratingScreen({super.key});
  @override
  ConsumerState<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends ConsumerState<GeneratingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _scan =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = await ref.read(generationProvider.notifier).run();
      if (mounted && p != null) context.pushReplacement('/result/${p.id}');
    });
  }

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final gen = ref.watch(generationProvider);
    final draft = ref.watch(draftProvider);
    return Scaffold(
      backgroundColor: C.accentTint,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(
                width: 240,
                height: 300,
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset(draft.photoAsset, fit: BoxFit.cover, alignment: const Alignment(0, -0.45)),
                  AnimatedBuilder(
                    animation: _scan,
                    builder: (_, _) => Align(
                      alignment: Alignment(0, -1 + 2 * _scan.value),
                      child: Container(
                        height: 46,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x0010A56A), Color(0x8810A56A), Color(0x0010A56A)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(s.t('gen.title'), textAlign: TextAlign.center, style: T.h1),
          const SizedBox(height: 6),
          Text('${draft.label} - usually 15-25 seconds', textAlign: TextAlign.center, style: T.caption),
          const SizedBox(height: 24),
          AppCard(
            child: Column(children: [
              for (var i = 1; i <= 4; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: gen.step >= i
                          ? const Icon(Icons.check_circle, color: C.success)
                          : gen.step == i - 1
                              ? const Padding(
                                  padding: EdgeInsets.all(3),
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: C.accentFill))
                              : const Icon(Icons.radio_button_unchecked, color: C.border),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s.t('gen.s$i'),
                          style: T.label.copyWith(color: gen.step >= i - 1 ? C.text : C.text3)),
                    ),
                  ]),
                ),
            ]),
          ),
          if (gen.error != null) ...[
            const SizedBox(height: 12),
            Text(gen.error!, style: const TextStyle(color: C.danger)),
          ],
          const SizedBox(height: 20),
          SecondaryButton(s.t('gen.cancel'), onPressed: () => context.pop()),
          const SizedBox(height: 12),
          Text(s.t('gen.note'), textAlign: TextAlign.center, style: T.caption),
        ]),
      ),
    );
  }
}

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final p = ref.watch(previewsProvider).where((e) => e.id == id).firstOrNull;
    if (p == null) return const Scaffold();
    final r = p.request;
    final chips = <String>[
      switch (r.type) {
        SimulationType.hair => r.hairStyle ?? 'Soft bob',
        SimulationType.makeup => r.makeupLook ?? 'Soft glam',
        SimulationType.filler => '${areaName(r.area ?? TreatmentArea.lips)} ${(r.area?.isBotox ?? false) ? 'Botox' : 'filler'}',
      },
      if (r.type == SimulationType.hair) r.hairColor ?? 'Chestnut',
      if (r.type == SimulationType.filler)
        (r.area?.isBotox ?? false) ? '${(r.amount ?? 20).round()} units' : '${(r.amount ?? 1).toStringAsFixed(1)} ml',
      if (r.type == SimulationType.filler && r.naturalLook) s.t('filler.natural'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('result.title')),
        actions: [IconButton(icon: const Icon(Icons.ios_share), onPressed: () {})],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
        SizedBox(height: 440, child: BeforeAfterSlider(preview: p)),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final c in chips) Tag(c)]),
        const SizedBox(height: 14),
        const Disclaimer(),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: SecondaryButton(s.t('result.retry'), onPressed: () => context.pop())),
          const SizedBox(width: 10),
          Expanded(
            child: p.sharedWithClinic
                ? Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: C.successTint, borderRadius: BorderRadius.circular(999)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check, color: C.success, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(s.t('history.sharedTag'),
                            style: const TextStyle(color: C.success, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  )
                : PrimaryButton(s.t('result.save'), key: const Key('saveClinic'), onPressed: () {
                    ref.read(previewsProvider.notifier).share(p.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('result.saved'))));
                  }),
          ),
        ]),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {
            ref.read(previewsProvider.notifier).delete(p.id);
            context.pop();
          },
          style: TextButton.styleFrom(foregroundColor: C.danger),
          icon: const Icon(Icons.delete_outline),
          label: Text(s.t('result.delete'), style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  SimulationType? _filter;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final all = ref.watch(previewsProvider);
    final list = _filter == null ? all : all.where((p) => p.request.type == _filter).toList();
    final shared = all.where((p) => p.sharedWithClinic).length;
    if (all.isEmpty) {
      return ListView(children: [
        ScreenHeader(s.t('history.title')),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(children: [
            const PhotoBox('assets/images/empty-history.jpg', height: 260, width: double.infinity),
            const SizedBox(height: 24),
            Text(s.t('history.empty'), style: T.h1),
            const SizedBox(height: 8),
            Text(s.t('history.emptySub'), textAlign: TextAlign.center, style: T.body.copyWith(color: C.text2)),
            const SizedBox(height: 24),
            PrimaryButton(s.t('history.emptyCta'), onPressed: () => context.go('/studio')),
          ]),
        ),
      ]);
    }
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      ScreenHeader(s.t('history.title')),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(children: [
          for (final (t, k) in [
            (null, 'history.all'),
            (SimulationType.hair, 'type.hair'),
            (SimulationType.makeup, 'type.makeup'),
            (SimulationType.filler, 'type.filler'),
          ])
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: MirraChip(s.t(k), selected: _filter == t, onTap: () => setState(() => _filter = t)),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${all.length}', style: T.display.copyWith(color: C.accentFill, fontSize: 40, height: 1)),
          const SizedBox(width: 8),
          Expanded(child: Text('${s.t('history.count')} - $shared ${s.t('history.shared')}', style: T.caption)),
        ]),
      ),
      GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 12, childAspectRatio: 0.7),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final p = list[i];
          return InkWell(
            key: Key('hist-${p.id}'),
            onTap: () => context.push('/result/${p.id}'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(fit: StackFit.expand, children: [
                    previewAfter(p),
                    const Positioned(left: 8, bottom: 8, child: AiBadge(small: true)),
                    if (p.sharedWithClinic)
                      Positioned(
                          right: 8,
                          top: 8,
                          child: Tag(s.t('history.sharedTag'), icon: Icons.storefront_outlined, bg: Colors.white)),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Text(p.request.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.label.copyWith(fontWeight: FontWeight.w600)),
              Text(shortDate(p.createdAt), style: T.caption),
            ]),
          );
        },
      ),
    ]);
  }
}
