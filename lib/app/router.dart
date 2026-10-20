import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/account/presentation/account_view_model.dart';
import '../features/account/presentation/onboarding_page.dart';
import '../features/account/presentation/settings_page.dart';
import '../features/account/presentation/welcome_page.dart';
import '../features/ai_review/presentation/review_page.dart';
import '../features/body_record/presentation/body_record_page.dart';
import '../features/calendar/presentation/calendar_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/training/presentation/training_page.dart';
import 'shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(accountViewModelProvider, (_, next) => refresh.value++);
  final router = GoRouter(
      initialLocation: '/welcome',
      refreshListenable: refresh,
      redirect: (context, state) {
        final account = ref.read(accountViewModelProvider);
        final public =
            ['/welcome', '/onboarding'].contains(state.matchedLocation);
        if (!account.isLoading && account.valueOrNull == null && !public) {
          return '/welcome';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),
        GoRoute(
            path: '/onboarding', builder: (_, __) => const OnboardingPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
        ShellRoute(
            builder: (_, state, child) =>
                AppShell(location: state.uri.path, child: child),
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomePage()),
              GoRoute(
                  path: '/training', builder: (_, __) => const TrainingPage()),
              GoRoute(
                  path: '/body', builder: (_, __) => const BodyRecordPage()),
              GoRoute(
                  path: '/calendar', builder: (_, __) => const CalendarPage()),
              GoRoute(path: '/review', builder: (_, __) => const ReviewPage()),
            ]),
      ],
      errorBuilder: (context, state) => Scaffold(
          body: Center(
              child: FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('ホームに戻る')))));
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
