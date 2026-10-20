import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/presentation/widgets.dart';
import '../../training/presentation/training_view_model.dart';
import 'review_view_model.dart';

class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewViewModelProvider);
    final training = ref.watch(trainingViewModelProvider).valueOrNull;
    final vm = ref.read(reviewViewModelProvider.notifier);
    return AsyncContent(
        value: state,
        retry: () => ref.invalidate(reviewViewModelProvider),
        builder: (reviews) => PageBody(children: [
              const PageHeading(
                  'WEEKLY REVIEW', '振り返りが、次の力になる。', '今週の記録から、来週のペースを考えましょう。'),
              const Panel(
                  color: Color(0xFFEAF0DC),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Chip(label: Text('AIレビュー・サンプル')),
                        Text(
                            '実際の記録を、固定ルールで集計するデモです。AIへの送信は行いません。週の途中でも確認でき、再作成すると今週のレビューを更新します。'),
                      ])),
              const SizedBox(height: 16),
              FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => runAction(context, vm.generate),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('今週のレビューを作成')),
              const SizedBox(height: 24),
              if (reviews.isEmpty)
                const EmptyState(
                    '一週間の振り返りを始めましょう', '今週のプランを採用し、トレーニングや体重を記録すると、ここで振り返れます。',
                    icon: Icons.auto_awesome_outlined),
              ...reviews.map((review) {
                final adopted =
                    training?.plans.any((p) => p.id == review.proposal.id) ??
                        false;
                return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Panel(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('${dayLabel(review.week)}からの1週間',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 20),
                          Text(
                              'トレーニング ${review.completedSessions}回 / 予定 ${review.plannedSessions}回'),
                          Text('記録したセット ${review.recordedSets}セット'),
                          Text(review.weightChange == null
                              ? '体重変化：期間内の記録が2件以上必要です'
                              : '体重変化：${review.weightChange! > 0 ? '+' : ''}${review.weightChange!.toStringAsFixed(1)}kg（期間内の初回→最新）'),
                          const Divider(height: 32),
                          Text('来週へのヒント',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(review.explanation),
                          const SizedBox(height: 16),
                          const Text(
                              '採用前に、次の画面で種目・回数・負荷を確認して編集できます。今週のプランや過去の実績は変わりません。'),
                          const SizedBox(height: 20),
                          FilledButton.tonalIcon(
                              onPressed: state.isLoading || adopted
                                  ? null
                                  : () async {
                                      final ok = await runAction(
                                          context, () => vm.propose(review));
                                      if (ok && context.mounted) {
                                        ref.invalidate(
                                            trainingViewModelProvider);
                                        context.go('/training');
                                      }
                                    },
                              icon: Icon(
                                  adopted ? Icons.check : Icons.arrow_forward),
                              label:
                                  Text(adopted ? 'この提案は採用済み' : '来週の提案を確認する')),
                        ])));
              }),
            ]));
  }
}
