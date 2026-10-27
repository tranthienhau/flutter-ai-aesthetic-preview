import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../billing/subscription.dart';
import '../data/mock_data.dart';
import '../state/providers.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});
  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final sub = ref.watch(subscriptionProvider);
    final now = ref.watch(nowProvider);
    final title = sub.status == SubStatus.trial && sub.trialDaysLeft(now) > 1
        ? '${s.t('sub.trial')} - ${sub.trialDaysLeft(now)}d'
        : sub.status == SubStatus.trial
            ? s.t('paywall.title')
            : s.t('paywall.expired');
    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        Stack(children: [
          Image.asset('assets/images/paywall-clinic.jpg',
              height: 280, width: double.infinity, fit: BoxFit.cover),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                  key: const Key('closePaywall'),
                  icon: const Icon(Icons.close, color: C.text),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/studio')),
            ),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title, style: T.display),
            const SizedBox(height: 18),
            AppCard(
              border: C.accentFill,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(s.t('paywall.plan'), style: T.title)),
                  Text(Plan.priceLabel, style: T.h1.copyWith(color: C.accentFill)),
                  const Text(' / mo', style: T.caption),
                ]),
                const Divider(height: 24, color: C.border),
                for (final k in ['paywall.b1', 'paywall.b2', 'paywall.b3'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline, color: C.success, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s.t(k), style: T.label)),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 14),
            Text(s.t('paywall.billing'), textAlign: TextAlign.center, style: T.caption),
            const SizedBox(height: 16),
            PrimaryButton(_busy ? '...' : s.t('paywall.cta'), key: const Key('subscribe'), onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    final ok = await ref.read(subscriptionProvider.notifier).purchase();
                    if (!context.mounted) return;
                    setState(() => _busy = false);
                    if (ok) context.canPop() ? context.pop() : context.go('/studio');
                  }),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton(
                  onPressed: () => ref.read(billingServiceProvider).restore(),
                  child: Text(s.t('paywall.restore'))),
              const Text('-', style: T.caption),
              TextButton(onPressed: () {}, child: const Text('Terms')),
              const Text('-', style: T.caption),
              TextButton(onPressed: () {}, child: const Text('Privacy')),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final he = ref.watch(localeProvider).languageCode == 'he';
    final sub = ref.watch(subscriptionProvider);
    Widget row(IconData i, String label, {VoidCallback? onTap, Widget? trailing, Key? key}) => ListTile(
          key: key,
          leading: Icon(i, color: C.accentFill),
          title: Text(label, style: T.label.copyWith(fontSize: 16)),
          trailing: trailing ?? const Icon(Icons.chevron_right, color: C.text3),
          onTap: onTap,
        );
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      ScreenHeader(s.t('account.title')),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(children: [
            row(Icons.workspace_premium_outlined, s.t('account.sub'),
                key: const Key('rowSubscription'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  _statusTag(s, sub.status),
                  const Icon(Icons.chevron_right, color: C.text3),
                ]),
                onTap: () => context.push('/subscription')),
            const Divider(height: 1, color: C.border, indent: 16, endIndent: 16),
            row(Icons.shield_outlined, s.t('account.privacy'),
                key: const Key('rowPrivacy'), onTap: () => context.push('/privacy')),
            const Divider(height: 1, color: C.border, indent: 16, endIndent: 16),
            row(Icons.translate, s.t('account.language'),
                key: const Key('rowLanguage'),
                trailing: Text(he ? 'עברית' : 'English', style: T.label.copyWith(color: C.accentFill)),
                onTap: () => ref.read(localeProvider.notifier).set(Locale(he ? 'en' : 'he'))),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: AppCard(
          color: C.surfaceAlt,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Demo controls', style: T.title),
            const SizedBox(height: 4),
            const Text('Simulate store time to show trial expiry and renewal.', style: T.caption),
            const SizedBox(height: 12),
            SecondaryButton('Advance clock +1 day', key: const Key('advanceDay'), onPressed: () {
              ref.read(clockOffsetProvider.notifier).advance(const Duration(days: 1));
            }),
          ]),
        ),
      ),
    ]);
  }
}

Widget _statusTag(dynamic s, SubStatus st) => switch (st) {
      SubStatus.trial => Tag(s.t('sub.trial')),
      SubStatus.active => Tag(s.t('sub.active'), fg: C.success, bg: C.successTint),
      SubStatus.cancelled => Tag(s.t('sub.cancelled'), fg: C.warning, bg: C.warningTint),
      SubStatus.expired => Tag(s.t('sub.expired'), fg: C.danger, bg: C.dangerTint),
      SubStatus.none => const SizedBox.shrink(),
    };

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final sub = ref.watch(subscriptionProvider);
    final now = ref.watch(nowProvider);
    final paid = sub.status == SubStatus.active || sub.status == SubStatus.cancelled;
    return Scaffold(
      appBar: AppBar(title: Text(s.t('account.sub'))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(s.t('paywall.plan'), style: T.title)),
              _statusTag(s, sub.status),
            ]),
            const SizedBox(height: 10),
            Text('${Plan.priceLabel} / month', style: T.display.copyWith(color: C.accentFill)),
            const SizedBox(height: 6),
            if (sub.status == SubStatus.trial)
              Text('${s.t('sub.trial')}: ${sub.trialDaysLeft(now)} days left - ends ${longDate(sub.trialEndsAt!)}',
                  style: T.caption),
            if (sub.status == SubStatus.active)
              Text('${s.t('sub.renews')} ${longDate(sub.periodEndsAt!)}', key: const Key('renewDate'), style: T.caption),
            if (sub.status == SubStatus.cancelled)
              Text('${s.t('sub.ends')} ${longDate(sub.periodEndsAt!)}', key: const Key('accessUntil'), style: T.caption),
            if (sub.status == SubStatus.active && sub.trialEndsAt != null)
              Text('Started after free trial on ${longDate(sub.trialEndsAt!)}', style: T.caption),
          ]),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: [
            ListTile(leading: const Icon(Icons.apple, color: C.text), title: Text(s.t('sub.payment'))),
            const Divider(height: 1, color: C.border, indent: 16, endIndent: 16),
            ListTile(
                leading: const Icon(Icons.restore, color: C.accentFill),
                title: Text(s.t('paywall.restore')),
                onTap: () => ref.read(billingServiceProvider).restore()),
            const Divider(height: 1, color: C.border, indent: 16, endIndent: 16),
            ListTile(leading: const Icon(Icons.receipt_long_outlined, color: C.accentFill), title: Text(s.t('sub.history'))),
          ]),
        ),
        const SizedBox(height: 16),
        if (!paid) PrimaryButton(s.t('sub.subscribe'), onPressed: () => context.push('/paywall')),
        if (sub.status == SubStatus.active)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.t('sub.cancelTitle'), style: T.title),
              const SizedBox(height: 6),
              Text(s.t('sub.cancelBody'), style: T.body.copyWith(color: C.text2)),
              const SizedBox(height: 14),
              SecondaryButton(s.t('sub.cancelCta'),
                  key: const Key('cancelSub'), danger: true, onPressed: () => _confirmCancel(context, ref)),
            ]),
          ),
        const SizedBox(height: 12),
        Text(s.t('sub.cancelNote'), textAlign: TextAlign.center, style: T.caption),
      ]),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final s = ref.read(stringsProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.t('sub.cancelTitle')),
        content: Text(s.t('sub.cancelBody')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep')),
          TextButton(
              key: const Key('confirmCancel'),
              style: TextButton.styleFrom(foregroundColor: C.danger),
              onPressed: () => Navigator.pop(c, true),
              child: Text(s.t('sub.cancelCta'))),
        ],
      ),
    );
    if (ok == true) await ref.read(subscriptionProvider.notifier).cancel();
  }
}

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final previews = ref.watch(previewsProvider);
    final share = ref.watch(clinicShareProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('privacy.title'))),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
        AppCard(
          child: Row(children: [
            Text('${previews.length * 2}', style: T.display.copyWith(fontSize: 44, color: C.accentFill)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.t('privacy.stored'), style: T.title),
                Text(s.t('privacy.auto'), style: T.caption),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: [
            SwitchListTile(
              value: share,
              onChanged: (v) => ref.read(clinicShareProvider.notifier).set(v),
              title: Text(s.t('privacy.clinic'), style: T.label),
            ),
            const Divider(height: 1, color: C.border, indent: 16, endIndent: 16),
            ListTile(title: Text(s.t('privacy.policy')), trailing: const Icon(Icons.chevron_right)),
            const Divider(height: 1, color: C.border, indent: 16, endIndent: 16),
            ListTile(title: Text(s.t('privacy.consent')), trailing: const Icon(Icons.chevron_right)),
            const Divider(height: 1, color: C.border, indent: 16, endIndent: 16),
            ListTile(title: Text(s.t('privacy.download')), trailing: const Icon(Icons.download_outlined)),
          ]),
        ),
        SectionTitle(s.t('privacy.delete')),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(children: [
            for (final p in previews.take(3))
              ListTile(
                leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(width: 44, height: 44, child: previewAfter(p))),
                title: Text(p.request.label, style: T.label),
                subtitle: Text(shortDate(p.createdAt), style: T.caption),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: C.danger),
                  onPressed: () => ref.read(previewsProvider.notifier).delete(p.id),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 18),
        SecondaryButton(s.t('privacy.deleteAll'), key: const Key('deleteAll'), danger: true, onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              content: Text(s.t('privacy.confirm')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep')),
                TextButton(
                    style: TextButton.styleFrom(foregroundColor: C.danger),
                    onPressed: () => Navigator.pop(c, true),
                    child: Text(s.t('privacy.deleteAll'))),
              ],
            ),
          );
          if (ok == true) {
            ref.read(previewsProvider.notifier).deleteAll();
            ref.read(onboardingProvider.notifier).revokeConsent();
          }
        }),
        const SizedBox(height: 12),
        Text(s.t('privacy.note'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: C.text2)),
      ]),
    );
  }
}
