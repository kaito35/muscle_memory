import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;
  static const paths = ['/home', '/training', '/body', '/calendar', '/review'];
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text('BODYMAKE',
              style: TextStyle(
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          actions: [
            const Chip(
                label: Text('DEMO',
                    style: TextStyle(fontSize: 10, letterSpacing: 1))),
            IconButton(
                tooltip: 'プロフィールと設定',
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.person_outline)),
            const SizedBox(width: 8)
          ]),
      body: SafeArea(top: false, child: child),
      bottomNavigationBar: NavigationBar(
          selectedIndex: paths.indexOf(location).clamp(0, 4),
          onDestinationSelected: (index) => context.go(paths[index]),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'ホーム'),
            NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined), label: 'トレーニング'),
            NavigationDestination(
                icon: Icon(Icons.monitor_weight_outlined), label: 'からだ'),
            NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined), label: 'カレンダー'),
            NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined), label: 'レビュー'),
          ]));
}
