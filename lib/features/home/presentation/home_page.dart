import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/presentation/widgets.dart';
import '../../body_record/presentation/record_dialogs.dart';
import '../../body_record/presentation/weight_chart.dart';
import 'home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncContent(
      value: ref.watch(homeViewModelProvider),
      retry: () {
        ref.invalidate(homeViewModelProvider);
      },
      builder: (summary) => PageBody(children: [
            PageHeading(
                '${dateLabel(summary.now)} · ${weekdays[summary.now.weekday - 1]}曜日',
                '${summary.profile?.name ?? 'ゲスト'}さん、\n今日も、自分のペースで。',
                '続けた分だけ、変化は少しずつ。'),
            Panel(
                color: const Color(0xFFE4EEC5),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TODAY’S FOCUS',
                          style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Text(
                          summary.training.activeSession != null
                              ? 'トレーニングの続きから'
                              : summary.plan == null
                                  ? '最初のプランを作ろう'
                                  : summary.today?.name ?? '今日は、リカバリーデイ。',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Text(summary.plan == null
                          ? '無理なく続けられる1週間を、一緒に組み立てましょう。'
                          : summary.today == null
                              ? '休むこともトレーニングの一部。体重や写真を記録して、変化を振り返ってみましょう。'
                              : '${summary.today!.exercises.length}種目 / 予定${summary.profile?.minutesPerSession ?? 45}分'),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                          onPressed: () => context.go('/training'),
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(summary.training.activeSession != null
                              ? '記録を再開する'
                              : 'トレーニングを見る')),
                    ])),
            const SectionTitle('今週の積み重ね'),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Panel(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    const Icon(Icons.fitness_center_outlined, size: 22),
                    const SizedBox(height: 12),
                    Text(
                        '${summary.completedThisWeek} / ${summary.plan?.days.length ?? 0}',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const Text('完了回数 / 予定回数'),
                  ]))),
              const SizedBox(width: 12),
              Expanded(
                  child: Panel(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    const Icon(Icons.monitor_weight_outlined, size: 22),
                    const SizedBox(height: 12),
                    Text(
                        summary.records.weights.isEmpty
                            ? '—'
                            : summary.records.weights.first.weight.kg
                                .toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineMedium),
                    const Text('最新の体重 / kg'),
                  ]))),
            ]),
            SectionTitle('からだの変化',
                trailing: TextButton(
                    onPressed: () => context.go('/body'),
                    child: const Text('すべて見る'))),
            Panel(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('直近30日の体重'),
                  const SizedBox(height: 16),
                  WeightChart(entries: summary.recentWeights)
                ])),
            const SizedBox(height: 16),
            OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const WeightEditorDialog()),
                icon: const Icon(Icons.add),
                label: const Text('今日の体重を記録')),
            const SectionTitle('一週間を振り返る'),
            Panel(
                child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.auto_awesome_outlined),
                    title: const Text('ウィークリーレビュー'),
                    subtitle: const Text('記録を見直して、次の一歩へ。'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => context.go('/review'))),
          ]));
}
