import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/domain_error.dart';
import '../../../core/presentation/widgets.dart';
import '../domain/training.dart';
import 'training_view_model.dart';
import 'workout_dialogs.dart';

class TrainingPage extends ConsumerWidget {
  const TrainingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trainingViewModelProvider);
    final vm = ref.read(trainingViewModelProvider.notifier);
    return AsyncContent(
        value: state,
        retry: () => ref.invalidate(trainingViewModelProvider),
        builder: (data) {
          final now = DateTime.now();
          final current = data.planFor(now);
          final next =
              data.planFor(weekStart(now).add(const Duration(days: 7)));
          return PageBody(children: [
            const PageHeading(
                'TRAINING', '一回ずつ、強くなる。', '予定と実績を分けて、今日のトレーニングを記録。'),
            if (data.activeSession != null) ...[
              const SectionTitle('進行中のトレーニング'),
              ActiveWorkout(
                  session: data.activeSession!, busy: state.isLoading),
            ],
            if (data.draft != null) ...[
              const SectionTitle('プランの提案'),
              Panel(
                  color: const Color(0xFFEAF0DC),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Chip(label: Text('未採用・サンプル提案')),
                        Text('${dayLabel(data.draft!.week)}からの1週間',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Text(data.draft!.explanation),
                        const SizedBox(height: 16),
                        const Text('種目ごとの編集ボタンで予定を調整できます。採用するまで現在のプランは変わりません。'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () => runAction(
                                    context, () => vm.adopt(data.draft!.id),
                                    success: 'プランを採用しました'),
                            icon: const Icon(Icons.check),
                            label: const Text('このプランを採用する')),
                      ])),
              const SizedBox(height: 12),
              ...data.draft!.days.map((day) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PlanDayCard(
                      day: day, draft: true, busy: state.isLoading))),
            ],
            const SectionTitle('今週のプラン'),
            if (current == null)
              EmptyState('はじめのプランを作りましょう', '週の回数と場所に合わせたサンプルを作成します。',
                  icon: Icons.fitness_center,
                  action: FilledButton(
                      onPressed: state.isLoading
                          ? null
                          : () => runAction(context, vm.propose),
                      child: const Text('サンプルプランを作成')))
            else ...[
              Text(
                  '${dayLabel(current.week)}〜${dayLabel(current.week.add(const Duration(days: 6)))} / 採用済み'),
              const SizedBox(height: 12),
              ...current.days.map((day) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PlanDayCard(
                      day: day,
                      draft: false,
                      busy: state.isLoading,
                      canStart: data.activeSession == null))),
              TextButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => runAction(context, vm.propose),
                  icon: const Icon(Icons.refresh),
                  label: const Text('今週の新しい提案を作る')),
            ],
            if (next != null) ...[
              const SectionTitle('来週のプラン'),
              Panel(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('${dayLabel(next.week)}から / 採用済み',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...next.days.map((day) =>
                        Text('${weekdays[day.weekday - 1]}曜日 · ${day.name}')),
                    const SizedBox(height: 8),
                    const Text('来週になると、今週のプランとして開始できます。'),
                  ])),
            ],
            const SectionTitle('トレーニング履歴'),
            if (!data.sessions.any((s) => s.isComplete))
              const EmptyState('最初の記録を待っています', 'トレーニングを完了すると、ここに実績が残ります。')
            else
              ...data.sessions.reversed.where((s) => s.isComplete).map((s) =>
                  Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SessionHistory(session: s))),
          ]);
        });
  }
}

class PlanDayCard extends ConsumerWidget {
  const PlanDayCard(
      {super.key,
      required this.day,
      required this.draft,
      required this.busy,
      this.canStart = false});
  final PlanDay day;
  final bool draft, busy, canStart;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Panel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${weekdays[day.weekday - 1]}曜日',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(day.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...day.exercises.map((target) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(target.name),
            subtitle: Text(
                '${target.kg == 0 ? '自重 / 負荷未設定' : '${target.kg} kg'} · ${target.reps}回 × ${target.sets}セット'),
            trailing: draft
                ? IconButton(
                    tooltip: '${target.name}の予定を編集',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: busy
                        ? null
                        : () => showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => WorkoutEntryDialog(
                                target: target, dayId: day.id)))
                : null)),
        if (!draft) ...[
          const SizedBox(height: 8),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: !canStart || busy
                      ? null
                      : () => runAction(
                          context,
                          () => ref
                              .read(trainingViewModelProvider.notifier)
                              .start(day.id)),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('このメニューを開始')))
        ],
      ]));
}

class ActiveWorkout extends ConsumerWidget {
  const ActiveWorkout({super.key, required this.session, required this.busy});
  final TrainingSession session;
  final bool busy;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Panel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.play_circle_outline),
          const SizedBox(width: 8),
          Expanded(
              child: Text(session.dayName,
                  style: Theme.of(context).textTheme.titleMedium))
        ]),
        const SizedBox(height: 12),
        Text('${session.sets.length} / ${session.plannedSets} セット記録済み'),
        const SizedBox(height: 8),
        LinearProgressIndicator(
            value: session.sets.length / session.plannedSets,
            borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 12),
        ...session.targets.map((target) =>
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Divider(height: 28),
              Text(target.name, style: Theme.of(context).textTheme.titleMedium),
              Text('予定 ${target.kg}kg × ${target.reps}回 × ${target.sets}セット'),
              const SizedBox(height: 8),
              ...List.generate(target.sets, (index) {
                final record = session.sets
                    .where((s) =>
                        s.exerciseId == target.id && s.number == index + 1)
                    .firstOrNull;
                return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                        radius: 17,
                        backgroundColor: record == null
                            ? const Color(0xFFF1F2EA)
                            : const Color(0xFFE4EEC5),
                        child: record == null
                            ? Text('${index + 1}',
                                style: const TextStyle(fontSize: 13))
                            : const Icon(Icons.check, size: 18)),
                    title: Text(record == null
                        ? 'セット ${index + 1}'
                        : '${record.kg}kg × ${record.reps}回'),
                    subtitle: record == null
                        ? null
                        : Text('きつさ ${record.exertion}/10'),
                    trailing: TextButton(
                        onPressed: busy
                            ? null
                            : () => showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => WorkoutEntryDialog(
                                    target: target,
                                    number: index + 1,
                                    existing: record)),
                        child: Text(record == null ? '記録' : '修正')));
              }),
            ])),
        const SizedBox(height: 16),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: busy
                    ? null
                    : () => showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const CompleteWorkoutDialog()),
                child: const Text('トレーニングを完了'))),
      ]));
}

class SessionHistory extends StatelessWidget {
  const SessionHistory({super.key, required this.session});
  final TrainingSession session;
  @override
  Widget build(BuildContext context) => Card(
          child: ExpansionTile(
              shape: const Border(),
              title: Text(session.dayName),
              subtitle: Text(
                  '${dateLabel(session.startedAt)} · ${session.sets.length}セット'),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
            ...session.targets.map((target) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(target.name),
                subtitle: Text(
                    '予定 ${target.kg}kg × ${target.reps}回 × ${target.sets}セット\n実績 ${session.sets.where((s) => s.exerciseId == target.id).map((s) => '${s.kg}kg × ${s.reps}回').join(' / ')}'))),
            Text('疲労度 ${session.fatigue}/10'),
            if (session.memo.isNotEmpty) Text(session.memo),
          ]));
}
