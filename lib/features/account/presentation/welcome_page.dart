import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/presentation/widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: PageBody(children: [
        const SizedBox(height: 32),
        const Row(children: [
          Icon(Icons.spa_outlined, size: 28),
          SizedBox(width: 10),
          Text('BODYMAKE',
              style: TextStyle(
                  fontSize: 19, letterSpacing: 3, fontWeight: FontWeight.w800))
        ]),
        const SizedBox(height: 56),
        const PageHeading('SMALL STEPS. REAL CHANGE.', '今日の積み重ねが、\n明日の自分になる。',
            'トレーニングも、からだの変化も。\nあなたのペースで続ける、ボディメイクノート。'),
        Panel(
            color: const Color(0xFFE4EEC5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.trending_up_rounded, size: 48),
              const SizedBox(height: 28),
              Text('記録する。振り返る。\n次の一歩を決める。',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              const Wrap(spacing: 8, runSpacing: 8, children: [
                Chip(label: Text('トレーニング')),
                Chip(label: Text('体重・写真')),
                Chip(label: Text('週次レビュー'))
              ]),
            ])),
        const SizedBox(height: 32),
        FilledButton.icon(
            onPressed: () => context.go('/onboarding'),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('デモをはじめる')),
        const SizedBox(height: 16),
        const Text(
            'アカウント登録不要の体験版です。認証・AIは仮実装です。\n記録と写真は再起動・再読み込みで消えます。外部への送信は行いません。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF72796C))),
      ])));
}
