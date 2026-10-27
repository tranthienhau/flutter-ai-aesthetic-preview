import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/account.dart';
import 'screens/clinic.dart';
import 'screens/onboarding.dart';
import 'screens/result.dart';
import 'screens/studio.dart';
import 'state/providers.dart';
import 'theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/signup', builder: (_, _) => const SignUpScreen()),
      GoRoute(path: '/consent', builder: (_, _) => const ConsentScreen()),
      GoRoute(path: '/photo', builder: (_, _) => const PhotoScreen()),
      GoRoute(path: '/hair', builder: (_, _) => const HairScreen()),
      GoRoute(path: '/makeup', builder: (_, _) => const MakeupScreen()),
      GoRoute(path: '/filler', builder: (_, _) => const FillerScreen()),
      GoRoute(path: '/generating', builder: (_, _) => const GeneratingScreen()),
      GoRoute(path: '/result/:id', builder: (_, st) => ResultScreen(id: st.pathParameters['id']!)),
      GoRoute(path: '/paywall', builder: (_, _) => const PaywallScreen()),
      GoRoute(path: '/subscription', builder: (_, _) => const SubscriptionScreen()),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyScreen()),
      GoRoute(path: '/clinic/client', builder: (_, _) => const ClinicClientScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => TabShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/studio', builder: (_, _) => const StudioScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/history', builder: (_, _) => const HistoryScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/clinic', builder: (_, _) => const ClinicScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/account', builder: (_, _) => const AccountScreen())]),
        ],
      ),
    ],
  );
});

class TabShell extends ConsumerWidget {
  const TabShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    const icons = [
      Icons.auto_awesome_outlined,
      Icons.photo_library_outlined,
      Icons.storefront_outlined,
      Icons.person_outline,
    ];
    final labels = [s.t('tab.studio'), s.t('tab.history'), s.t('tab.clinic'), s.t('tab.account')];
    return Scaffold(
      body: SafeArea(bottom: false, child: shell),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.border))),
        child: NavigationBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: C.accentTint,
          height: 68,
          selectedIndex: shell.currentIndex,
          labelTextStyle: WidgetStateProperty.resolveWith((st) => TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: st.contains(WidgetState.selected) ? C.accentFill : C.text3,
              )),
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            for (var i = 0; i < 4; i++)
              NavigationDestination(
                key: Key('tab$i'),
                icon: Icon(icons[i], color: C.text3),
                selectedIcon: Icon(icons[i], color: C.accentFill),
                label: labels[i],
              ),
          ],
        ),
      ),
    );
  }
}
