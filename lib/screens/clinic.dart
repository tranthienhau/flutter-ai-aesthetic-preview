import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../state/providers.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ClinicScreen extends ConsumerWidget {
  const ClinicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final sessions = ref.watch(clinicSessionsProvider);
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      ScreenHeader(s.t('clinic.today'), caption: s.t('clinic.name')),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(gradient: C.heroGradient, borderRadius: BorderRadius.circular(R.card)),
          child: Row(children: [
            Text('8', style: T.display.copyWith(color: Colors.white, fontSize: 56, height: 1)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.t('clinic.sessions'),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(s.t('clinic.mix'), style: const TextStyle(color: Colors.white, fontSize: 14)),
              ]),
            ),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(children: [
          Expanded(child: _Stat('23', s.t('clinic.sharedWeek'))),
          const SizedBox(width: 12),
          Expanded(child: _Stat('61%', s.t('clinic.booked'))),
        ]),
      ),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SectionTitle(s.t('clinic.list'))),
      for (final c in sessions)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              key: Key('session-${c.client}'),
              onTap: () => context.push('/clinic/client'),
              child: Row(children: [
                Avatar(c.avatar, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.client, style: T.label.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${c.time} - ${c.treatment}', style: T.caption),
                  ]),
                ),
                if (c.shared) Tag(s.t('history.sharedTag')),
                const Icon(Icons.chevron_right, color: C.text3),
              ]),
            ),
          ),
        ),
    ]);
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: T.h1.copyWith(color: C.accentFill)),
          const SizedBox(height: 2),
          Text(label, style: T.caption),
        ]),
      );
}

class ClinicClientScreen extends ConsumerWidget {
  const ClinicClientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final previews = ref.watch(previewsProvider);
    final latest = previews.where((p) => p.sharedWithClinic).firstOrNull;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 28), children: [
        Row(children: [
          const Avatar('assets/images/avatar-noa.jpg', size: 68),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Noa Levi', style: T.h1),
              Text(s.t('clinic.since'), style: T.caption),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          Tag(s.t('clinic.consent'), icon: Icons.verified_outlined),
          Tag(s.t('clinic.verified'), icon: Icons.badge_outlined),
        ]),
        const SizedBox(height: 16),
        if (latest != null)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 200,
                child: Row(children: [
                  Expanded(child: PhotoBox(latest.beforeAsset, radius: 14, alignment: const Alignment(0, -0.4))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(fit: StackFit.expand, children: [
                        previewAfter(latest),
                        const Positioned(left: 6, bottom: 6, child: AiBadge(small: true)),
                      ]),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Text('${latest.request.label} - ${shortDate(latest.createdAt)}', style: T.title.copyWith(fontSize: 17)),
            ]),
          ),
        SectionTitle(s.t('clinic.timeline')),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: [
            for (final p in previews)
              ListTile(
                leading: Icon(p.sharedWithClinic ? Icons.check_circle_outline : Icons.lock_outline,
                    color: p.sharedWithClinic ? C.success : C.text3),
                title: Text(p.request.label,
                    style: T.label.copyWith(color: p.sharedWithClinic ? C.text : C.text3)),
                subtitle: Text(shortDate(p.createdAt), style: T.caption),
                trailing: p.sharedWithClinic
                    ? Tag(s.t('history.sharedTag'))
                    : Tag(s.t('clinic.private'), fg: C.text2, bg: C.surfaceAlt),
              ),
          ]),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: 'Prefers natural look, start 0.7 ml.',
          maxLines: 3,
          decoration: InputDecoration(labelText: s.t('clinic.note')),
        ),
        const SizedBox(height: 16),
        PrimaryButton(s.t('clinic.book'), icon: Icons.event_available_outlined, onPressed: () {}),
      ]),
    );
  }
}
